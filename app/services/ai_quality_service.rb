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
    fake_terms = ['acme corp', 'lorem ipsum', 'john doe', 'jane doe']
    if fake_terms.any? { |t| content.to_s.downcase.include?(t) }
      score -= 80
      reasons << "Contains placeholder or fake text."
    end

    # Simple JSON format check for actions that expect JSON
    json_actions = %w[tailor_to_job optimize ats_booster linkedin_optimizer achievement_generator translator]
    if json_actions.include?(action)
      begin
        JSON.parse(content)
      rescue JSON::ParserError
        score -= 90
        reasons << "Failed JSON parsing."
      end
    end

    # Empty check
    if content.blank? || content.to_s.strip == 'None'
      score -= 100
      reasons << "Output is empty."
    end

    {
      score: [score, 0].max,
      passed: score >= 70,
      reasons: reasons
    }
  end
end
