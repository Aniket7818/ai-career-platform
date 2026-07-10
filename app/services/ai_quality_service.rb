class AiQualityService
  def self.evaluate(content, action, payload = {})
    score = 100
    reasons = []

    # Length check
    min_length = %w[improve_skills ats_booster optimize_project].include?(action) ? 2 : 20
    if content.to_s.length < min_length
      score -= 50
      reasons << "Content is suspiciously short."
    end

    # Hallucination / fake checks (generic, applied to all actions except cover letter which has custom ones)
    if action != "generate_cover_letter"
      fake_terms = [ "acme corp", "lorem ipsum", "john doe", "jane doe" ]
      if fake_terms.any? { |t| content.to_s.downcase.include?(t) }
        score -= 80
        reasons << "Contains placeholder or fake text."
      end
    end

    # Cover letter specific validations
    if action == "generate_cover_letter"
      # metadata leakages
      metadata_patterns = [
        "Hiring Manager:", "Company:", "Role:", "Job Description:", "Target Role:", 
        "Applicant:", "Resume:", "Input:", "Metadata:", "Hiring Manager at"
      ]
      if metadata_patterns.any? { |p| content.to_s.include?(p) }
        score -= 80
        reasons << "Contains metadata labels or leakage."
      end

      # Greeting checks
      if content.to_s.match?(/Dear .*, Hiring Manager/i) || content.to_s.match?(/Dear Hiring Manager at/i)
        score -= 80
        reasons << "Invalid greeting containing role/metadata."
      end

      # Extract company name & hiring manager from payload/instructions for custom checking
      company_name = payload[:company_name] || payload[:company]
      hiring_manager = payload[:hiring_manager]
      instructions = payload[:instructions].to_s

      company_name ||= instructions.match(/Company:\s*(.*?)\s*\.\s*Hiring Manager:/i)&.captures&.first
      hiring_manager ||= instructions.match(/Hiring Manager:\s*(.*?)\s*\.\s*Tone:/i)&.captures&.first

      # Check for "Acme" placeholder unless company_name is explicitly Acme
      if !company_name.to_s.downcase.include?("acme") && content.to_s.downcase.include?("acme")
        score -= 80
        reasons << "Contains placeholder company name 'Acme'."
      end

      # Check for "John Doe" placeholder unless hiring_manager is John Doe/John
      if !hiring_manager.to_s.downcase.include?("john") && content.to_s.downcase.include?("john doe")
        score -= 80
        reasons << "Contains placeholder name 'John Doe'."
      end

      # Generic placeholders
      placeholders = ["company name", "hiring manager name", "your name", "lorem ipsum", "test@example.com", "+1-555"]
      if placeholders.any? { |p| content.to_s.downcase.include?(p) }
        score -= 80
        reasons << "Contains placeholder text."
      end
    end

    # Soft JSON format check — LLMs may return valid prose; only deduct lightly
    # A hard block here (score -= 90) would break legitimate prose responses
    json_actions = %w[ats_booster linkedin_optimizer achievement_generator generate_linkedin]
    if json_actions.include?(action)
      begin
        JSON.parse(content)
      rescue JSON::ParserError
        # Try to extract JSON from markdown code blocks (```json ... ```)
        extracted = content.match(/```(?:json)?\s*(\[.*?\]|\{.*?\})\s*```/m)&.captures&.first
        json_valid = begin
          extracted && JSON.parse(extracted)
        rescue JSON::ParserError
          false
        end
        unless json_valid
          score -= 20
          reasons << "JSON format expected but received prose (acceptable)."
        end
      end
    end

    # Empty check
    if content.blank? || content.to_s.strip == "None"
      score -= 100
      reasons << "Output is empty."
    end

    {
      score: [ score, 0 ].max,
      passed: score >= 70,
      reasons: reasons
    }
  end
end
