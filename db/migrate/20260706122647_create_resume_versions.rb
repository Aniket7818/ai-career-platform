class CreateResumeVersions < ActiveRecord::Migration[7.2]
  def change
    create_table :resume_versions do |t|
      t.references :resume, null: false, foreign_key: true
      t.references :user,   null: false, foreign_key: true

      # Auto-incrementing version number scoped per resume (1, 2, 3…)
      t.integer :version_number, null: false, default: 1

      # Human-readable label, e.g. "Original", "Optimization #1", "Tailored for Google"
      t.string :label, null: false, default: "Original"

      # Full snapshot of resume.content at this point in time
      t.jsonb :content_snapshot, null: false, default: {}

      # AI-generated (or auto-generated) description of what changed in this version
      t.text :change_summary

      # Tracks which version is the currently active one for this resume
      t.boolean :is_current, null: false, default: false

      # Where did this version come from?
      # Allowed: "manual", "optimization", "tailoring", "restore"
      t.string :source, null: false, default: "manual"

      # Snapshot of the overall optimization score when this version was created.
      # Populated once Phase 3.2 (ResumeScoreService) is implemented.
      t.integer :score_at_creation

      t.timestamps
    end

    # Efficient lookup of all versions for a given resume, ordered by time
    add_index :resume_versions, [ :resume_id, :created_at ]

    # Fast lookup of the currently active version for a resume
    add_index :resume_versions, [ :resume_id, :is_current ]

    # Enforce unique version numbers per resume at the DB level
    add_index :resume_versions, [ :resume_id, :version_number ], unique: true

    # Filter by source across the whole table (admin analytics)
    add_index :resume_versions, :source
  end
end
