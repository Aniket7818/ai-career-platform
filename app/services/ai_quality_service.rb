class AiQualityService
  def self.evaluate(content, action)
    score = 100
    reasons = []

    # Length check
    if content.to_s.length < 20
      score -= 50
      reasons << "Content is suspiciously short."
    end

    # Hallucination / fake checks
    fake_terms = [ "acme corp", "lorem ipsum", "john doe", "jane doe" ]
    if fake_terms.any? { |t| content.to_s.downcase.include?(t) }
      score -= 80
      reasons << "Contains placeholder or fake text."
    end

    # Soft JSON format check — LLMs may return valid prose; only deduct lightly
    # A hard block here (score -= 90) would break legitimate prose responses
    json_actions = %w[ats_booster linkedin_optimizer achievement_generator]
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
