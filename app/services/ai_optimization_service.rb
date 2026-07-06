class AiOptimizationService
  class OptimizationError < StandardError; end

  def self.optimize(resume, action, payload = {}, request_meta = {})
    feature = case action
              when 'generate_summary' then 'resume_summary'
              when 'rewrite_experience', 'rewrite', 'expand', 'shorten' then 'resume_rewrite'
              when 'improve_skills' then 'skill_suggestions'
              when 'optimize', 'tailor_to_job' then 'tailor_resume'
              when 'generate_cover_letter' then 'cover_letter'
              when 'generate_linkedin' then 'linkedin_optimizer'
              when 'ats_booster' then 'ats_booster'
              when 'translator' then 'translator'
              when 'achievement_generator' then 'achievement_generator'
              else 'resume_rewrite' # default
              end

    instructions = payload[:instructions] || action
    
    # Add JD if provided
    if payload[:job_description].present?
      instructions += "\n\nTarget Job Description:\n#{payload[:job_description]}"
    end

    response_text = AiService.generate(
      user: resume.user,
      resume: resume,
      feature: feature,
      context: { 
        resume_content: resume.content.to_json,
        target_role: payload[:target_role] || resume.content["target_role"] || "Professional"
      },
      instructions: instructions,
      force_new: true,
      request_meta: request_meta
    )

    # Parse response (assuming JSON for updates, or raw text for cover letters)
    parsed = parse_response(response_text, action)
    
    apply_update(resume, action, parsed, payload)

    version_label = generate_label(action)
    
    # Save the new version
    ResumeVersionService.snapshot(
      resume,
      label: version_label,
      source: "optimization",
      change_summary: "AI optimization applied: #{action}",
      force: true
    )

    # Re-calculate score
    ResumeScoreService.calculate(resume)

    { success: true, message: "Optimization applied successfully", resume: resume.as_json, result: parsed }
  rescue => e
    Rails.logger.error "AiOptimizationService Error: #{e.message}"
    raise OptimizationError, e.message
  end

  private

  def self.parse_response(text, action)
    # Attempt JSON parse if it looks like JSON
    if text.strip.start_with?("{") || text.strip.start_with?("[")
      begin
        return JSON.parse(text)
      rescue JSON::ParserError
        return text
      end
    end
    text
  end

  def self.apply_update(resume, action, parsed, payload)
    content = resume.content || {}
    case action
    when 'generate_summary'
      content["summary"] = parsed.is_a?(Hash) ? parsed["summary"] : parsed
    when 'rewrite_experience', 'rewrite', 'expand', 'shorten', 'achievement_generator'
      # Just appending to summary for now to demonstrate it worked, 
      # since we don't have the specific bullet index from the frontend
      content["summary"] = (content["summary"] || "") + "\n\n[#{action.upcase} RESULT]\n" + (parsed.is_a?(Hash) ? parsed.to_json : parsed)
    when 'improve_skills', 'ats_booster'
      content["skills"] ||= []
      new_skills = parsed.is_a?(Array) ? parsed : [parsed.is_a?(Hash) ? parsed.to_json : parsed]
      content["skills"] = (content["skills"] + new_skills).uniq
    when 'generate_cover_letter', 'generate_linkedin', 'translator'
      content["ai_generated_#{action}"] = parsed.is_a?(Hash) ? parsed.to_json : parsed
    when 'optimize', 'tailor_to_job'
      content["tailored_summary"] = parsed.is_a?(Hash) ? parsed.to_json : parsed
    end
    
    resume.update!(content: content)
  end

  def self.generate_label(action)
    case action
    when 'generate_summary' then "Generated Summary"
    when 'rewrite_experience', 'rewrite' then "Rewrote Experience"
    when 'expand' then "Expanded Bullets"
    when 'shorten' then "Shortened Bullets"
    when 'improve_skills' then "Improved Skills"
    when 'optimize', 'tailor_to_job' then "Tailored to Job"
    when 'generate_cover_letter' then "Generated Cover Letter"
    when 'generate_linkedin' then "Generated LinkedIn Profile"
    when 'ats_booster' then "Added ATS Keywords"
    when 'translator' then "Translated Resume"
    when 'achievement_generator' then "Generated Achievements"
    else "AI Optimization"
    end
  end
end
