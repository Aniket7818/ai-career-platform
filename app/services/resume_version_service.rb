# ResumeVersionService manages the full lifecycle of resume version snapshots.
#
# Core principles:
#   1. NEVER destructive — restoring a version creates a new version, it never
#      overwrites the existing version history.
#   2. Atomic — all DB writes inside a single transaction. If any step fails,
#      nothing is committed.
#   3. Single source of truth — is_current is managed ONLY by this service.
#      No other code should touch is_current directly.
#   4. Idempotent snapshots — if the resume content hasn't changed since the
#      last version, we skip creating a duplicate (except for labeled versions
#      like "Tailored for Google" which are always created).
#
# Usage:
#   ResumeVersionService.create_initial(resume)
#   ResumeVersionService.snapshot(resume, label: "Optimization #1", source: "optimization")
#   ResumeVersionService.restore(version_id: 42, user: current_user)
#   ResumeVersionService.diff(version_a, version_b)
#   ResumeVersionService.list(resume)
class ResumeVersionService
  # ─── Errors ─────────────────────────────────────────────────────────────────
  class VersionNotFoundError  < StandardError; end
  class AccessDeniedError     < StandardError; end
  class NothingChangedError   < StandardError; end

  # ─── create_initial ──────────────────────────────────────────────────────────
  # Called when a resume is first saved. Creates the "Original" (v1) snapshot.
  # Safe to call multiple times — will skip if v1 already exists.
  #
  # @param resume [Resume]
  # @return [ResumeVersion, nil] the new version, or nil if already initialized
  def self.create_initial(resume)
    return nil if resume.resume_versions.exists?

    ActiveRecord::Base.transaction do
      ResumeVersion.create!(
        resume:           resume,
        user:             resume.user,
        version_number:   1,
        label:            "Original",
        source:           "manual",
        content_snapshot: deep_copy(resume.content),
        change_summary:   "Initial version",
        is_current:       true
      )
    end
  end

  # ─── snapshot ────────────────────────────────────────────────────────────────
  # Creates a new version snapshot of the resume's current content.
  #
  # Skips creation if:
  #   - force: false (default) AND the content hasn't changed since the last snapshot
  #
  # Always creates if:
  #   - force: true, OR
  #   - a non-"manual" source is passed (optimization, tailoring, restore always create)
  #
  # @param resume [Resume]
  # @param label [String] human-readable label for this version
  # @param source [String] one of ResumeVersion::SOURCES
  # @param change_summary [String, nil] description of what changed
  # @param score_at_creation [Integer, nil] optimization score (Phase 3.2)
  # @param force [Boolean] skip duplicate-content check
  # @return [ResumeVersion] the new version record
  def self.snapshot(resume, label:, source: "manual", change_summary: nil, score_at_creation: nil, force: false)
    unless ResumeVersion::SOURCES.include?(source)
      raise ArgumentError, "Invalid source '#{source}'. Must be one of: #{ResumeVersion::SOURCES.join(', ')}"
    end

    ActiveRecord::Base.transaction do
      last = resume.resume_versions.order(version_number: :desc).first

      # Skip duplicate snapshots for manual saves (prevents bloat from autosave)
      if !force && source == "manual" && last.present?
        last_content = last.content_snapshot.to_json
        current_content = resume.content.to_json
        if last_content == current_content
          Rails.logger.info "[ResumeVersionService] SKIP duplicate snapshot resume=#{resume.id}"
          raise NothingChangedError, "No changes since last version"
        end
      end

      next_number = (last&.version_number || 0) + 1

      # Mark all existing versions as not current
      resume.resume_versions.where(is_current: true).update_all(is_current: false)

      version = ResumeVersion.create!(
        resume:           resume,
        user:             resume.user,
        version_number:   next_number,
        label:            label,
        source:           source,
        content_snapshot: deep_copy(resume.content),
        change_summary:   change_summary,
        score_at_creation: score_at_creation,
        is_current:       true
      )

      Rails.logger.info "[ResumeVersionService] SNAPSHOT resume=#{resume.id} version=#{next_number} source=#{source} label=#{label.inspect}"
      version
    end
  end

  # ─── restore ─────────────────────────────────────────────────────────────────
  # Restores a previous version's content onto the live resume.
  # NON-DESTRUCTIVE: creates a new "restore" version rather than modifying history.
  #
  # @param version_id [Integer] ID of the ResumeVersion to restore
  # @param user [User] must own the resume (access check)
  # @return [ResumeVersion] the newly created "restore" version
  def self.restore(version_id:, user:)
    target = ResumeVersion.find_by(id: version_id)
    raise VersionNotFoundError, "Version not found" unless target
    raise AccessDeniedError, "Access denied" unless target.resume.user_id == user.id

    ActiveRecord::Base.transaction do
      resume = target.resume

      # Apply old content back to the live resume
      resume.update!(content: deep_copy(target.content_snapshot))

      # Create a new "restore" version that records what we restored from
      restore_label = "Restored from #{target.label}"
      restore_summary = "Restored content from version #{target.version_number} (#{target.label})"

      new_version = snapshot(
        resume,
        label:          restore_label,
        source:         "restore",
        change_summary: restore_summary,
        force:          true
      )

      Rails.logger.info "[ResumeVersionService] RESTORE resume=#{resume.id} from_version=#{target.version_number} new_version=#{new_version.version_number}"
      new_version
    end
  end

  # ─── list ────────────────────────────────────────────────────────────────────
  # Returns all versions for a resume, newest first, without content_snapshot
  # (the large JSONB blob) to keep the list response lightweight.
  #
  # @param resume [Resume]
  # @return [Array<ResumeVersion>]
  def self.list(resume)
    resume.resume_versions.reverse_chrono
  end

  # ─── find_with_access_check ──────────────────────────────────────────────────
  # Fetches a version and raises if the user doesn't own the associated resume.
  #
  # @param version_id [Integer]
  # @param user [User]
  # @return [ResumeVersion]
  def self.find_with_access_check(version_id, user)
    version = ResumeVersion.includes(:resume).find_by(id: version_id)
    raise VersionNotFoundError, "Version not found" unless version
    raise AccessDeniedError, "Access denied" unless version.resume.user_id == user.id
    version
  end

  # ─── diff ────────────────────────────────────────────────────────────────────
  # Produces a structured diff between two versions' content snapshots.
  # Returns a hash showing added, removed, and changed fields at the top level
  # of each resume content section.
  #
  # This is a structural diff — not a text diff. It compares the JSON structure
  # of both snapshots and returns a per-section report.
  #
  # @param version_a [ResumeVersion] "before" version (older)
  # @param version_b [ResumeVersion] "after" version (newer)
  # @return [Hash] { sections: { section_key => { status: "changed"|"added"|"removed"|"same" } } }
  def self.diff(version_a, version_b)
    snap_a = version_a.content_snapshot.to_h
    snap_b = version_b.content_snapshot.to_h

    all_keys = (snap_a.keys + snap_b.keys).uniq
    changes  = {}

    all_keys.each do |key|
      val_a = snap_a[key]
      val_b = snap_b[key]

      status = if val_a.nil?
        "added"
      elsif val_b.nil?
        "removed"
      elsif val_a.to_json == val_b.to_json
        "same"
      else
        "changed"
      end

      changes[key] = {
        status:  status,
        before:  val_a,
        after:   val_b
      }
    end

    {
      version_a:       version_a.api_json,
      version_b:       version_b.api_json,
      sections:        changes,
      has_any_changes: changes.values.any? { |c| c[:status] != "same" }
    }
  end

  private

  # Creates a deep copy of the content hash to prevent shared object references
  # from silently mutating a snapshot.
  def self.deep_copy(hash)
    JSON.parse(hash.to_json)
  rescue JSON::ParserError
    {}
  end
end
