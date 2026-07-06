class ResumeSerializer
  def initialize(resume)
    @resume = resume
  end

  def as_json(*)
    {
      id:                  @resume.id,
      title:               @resume.title,
      status:              @resume.status,
      template_id:         @resume.template_id,
      content:             @resume.content,
      # Phase 3.1: Target role — persisted on resume so optimization can use it
      target_role:         @resume.target_role,
      # Phase 3.1: Optimization score cache — populated by ResumeScoreService (Phase 3.2)
      last_analysis_score: @resume.last_analysis_score,
      last_analyzed_at:    @resume.last_analyzed_at,
      # Convenience count so the frontend can show "3 versions" in the list view
      version_count:       @resume.resume_versions.count,
      created_at:          @resume.created_at,
      updated_at:          @resume.updated_at
    }
  end
end
