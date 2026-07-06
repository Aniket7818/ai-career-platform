module ScoreEngine
  class ContentCompletenessChecker
    def initialize(resume)
      @resume = resume
      @content = resume.content || {}
    end

    def evaluate
      sections = %w[personal summary experiences education skills projects certifications]
      
      results = {}
      total_score = 0

      sections.each do |sec|
        status, points, reasoning = evaluate_section(sec)
        results[sec] = { status: status, reasoning: reasoning }
        total_score += points
      end

      # Normalize score to 100
      max_possible = 100 # Adjust based on weights
      final_score = (total_score.to_f / max_possible * 100).round
      final_score = 100 if final_score > 100
      final_score = 0 if final_score < 0

      {
        score: final_score,
        section_results: results
      }
    end

    private

    def evaluate_section(sec)
      val = @content[sec]
      
      case sec
      when 'personal'
        if val.present? && val['fullName'].present? && val['email'].present?
          ['complete', 15, 'Personal information is complete.']
        elsif val.present?
          ['weak', 5, 'Personal information is missing key fields like name or email.']
        else
          ['missing', 0, 'Personal information section is entirely missing.']
        end
      when 'summary'
        if val.present? && val.is_a?(String) && val.length > 50
          ['complete', 10, 'Summary is detailed and present.']
        elsif val.present?
          ['weak', 5, 'Summary is too brief.']
        else
          ['missing', 0, 'Summary section is missing.']
        end
      when 'experiences'
        if val.present? && val.is_a?(Array) && val.any?
          if val.all? { |e| e['company'].present? && e['role'].present? && e['description'].present? }
            ['complete', 30, 'Experience section is detailed.']
          else
            ['weak', 15, 'Some experience entries are missing company, role, or description.']
          end
        else
          ['missing', 0, 'Experience section is missing.']
        end
      when 'education'
        if val.present? && val.is_a?(Array) && val.any?
          ['complete', 20, 'Education section is present.']
        else
          ['missing', 0, 'Education section is missing.']
        end
      when 'skills'
        if val.present?
          ['complete', 15, 'Skills section is present.']
        else
          ['missing', 0, 'Skills section is missing.']
        end
      when 'projects'
        if val.present? && val.is_a?(Array) && val.any?
          ['complete', 10, 'Projects section is present.']
        else
          ['missing', 0, 'Projects section is missing, but it is optional.']
        end
      when 'certifications'
        if val.present? && val.is_a?(Array) && val.any?
          ['complete', 0, 'Certifications section is present (bonus).']
        else
          ['missing', 0, 'Certifications section is missing (optional).']
        end
      else
        ['missing', 0, 'Unknown section.']
      end
    end
  end
end
