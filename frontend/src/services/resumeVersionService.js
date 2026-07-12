/**
 * resumeVersionService — Frontend API client for the resume version history endpoints.
 *
 * All calls are scoped to a specific resume via the resumeId parameter.
 * Maps to: /api/v1/resumes/:resumeId/versions/...
 */
import http from './http'

export const resumeVersionService = {
  /**
   * List all versions for a resume (lightweight — no content_snapshot in response).
   * @param {number|string} resumeId
   * @returns {Promise} { resume_id, versions: [...] }
   */
  list: (resumeId) => http.get(`/resumes/${resumeId}/versions`),

  /**
   * Get a single version including its full content snapshot.
   * Used when the user previews or is about to restore a version.
   * @param {number|string} resumeId
   * @param {number|string} versionId
   * @returns {Promise} { version: { ...api_json_with_content } }
   */
  show: (resumeId, versionId) => http.get(`/resumes/${resumeId}/versions/${versionId}`),

  /**
   * Restore a specific version.
   * Creates a new "restore" snapshot on the backend (non-destructive).
   * Returns both the new version and the updated resume.
   * @param {number|string} resumeId
   * @param {number|string} versionId
   * @returns {Promise} { message, new_version, resume }
   */
  restore: (resumeId, versionId) =>
    http.post(`/resumes/${resumeId}/versions/${versionId}/restore`),

  /**
   * Get a structural diff between two versions.
   * @param {number|string} resumeId
   * @param {number|string} versionAId — the "before" (older) version
   * @param {number|string} versionBId — the "after" (newer) version
   * @returns {Promise} { diff: { version_a, version_b, sections, has_any_changes } }
   */
  diff: (resumeId, versionAId, versionBId) =>
    http.get(`/resumes/${resumeId}/versions/diff`, {
      params: { a: versionAId, b: versionBId }
    })
}
