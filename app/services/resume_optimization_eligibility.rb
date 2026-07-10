class ResumeOptimizationEligibility
  def self.check(resume, action)
    # Project optimization is always eligible — skip the expensive DB analysis
    return { eligible: true, message: nil } if action == "optimize_project"

    # Ensure fresh score analysis for eligibility checks
    analysis = ResumeScoreService.analyze(resume)

    
    # Defaults
    eligible = true
    message = nil

    case action
    when "generate_summary"
      # Allow continuous re-optimization for summary
      eligible = true
      
    when "improve_skills", "ats_booster"
      # Allow continuous re-optimization for skills without artificial gating
      eligible = true

    when "optimize", "tailor_to_job"
      # Allow continuous re-optimization
      eligible = true
    end

    { eligible: eligible, message: message }
  end
end
