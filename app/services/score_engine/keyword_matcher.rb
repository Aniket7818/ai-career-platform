module ScoreEngine
  class KeywordMatcher
    def initialize(resume)
      @resume = resume
      @content = ResumeContentNormalizer.normalize(resume.content)
    end

    def evaluate
      text = @content.to_json.downcase
      
      # Sample dictionaries for basic keyword matching
      hard_skills_dict = %w[ruby python java javascript react vue node sql aws docker kubernetes agile scrum git]
      soft_skills_dict = %w[leadership communication teamwork problem-solving time-management critical-thinking adaptability]

      found_hard = []
      found_soft = []

      hard_skills_dict.each do |skill|
        found_hard << skill if text.include?(skill)
      end

      soft_skills_dict.each do |skill|
        found_soft << skill if text.include?(skill)
      end

      # Scoring logic
      score = 0
      score += 50 if found_hard.size > 2
      score += 20 if found_hard.size > 5
      score += 15 if found_soft.size > 1
      score += 15 if found_soft.size > 3

      score = 100 if score > 100

      {
        score: score,
        hard_skills_found: found_hard,
        soft_skills_found: found_soft,
        suggestions: generate_suggestions(found_hard, found_soft)
      }
    end

    private

    def generate_suggestions(hard, soft)
      sug = []
      sug << "Consider adding more hard skills (e.g., specific technologies)." if hard.size < 3
      sug << "Consider adding more soft skills to show well-roundedness." if soft.size < 2
      sug << "Great job including both hard and soft skills." if hard.size >= 3 && soft.size >= 2
      sug
    end
  end
end
