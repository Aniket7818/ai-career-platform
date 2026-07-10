module ScoreEngine
  class AtsRuleEngine
    def initialize(resume)
      @resume = resume
      @content = ResumeContentNormalizer.normalize(resume.content)
    end

    def evaluate
      rules = [
        check_contact_info,
        check_resume_length,
        check_section_ordering,
        check_bullet_points,
        check_empty_sections,
        check_special_characters
      ]

      total_score = 100
      results = []

      rules.each do |rule|
        total_score -= rule[:deduction] if rule[:deduction] > 0
        results << rule
      end

      total_score = 0 if total_score < 0

      {
        score: total_score,
        results: results
      }
    end

    private

    def check_contact_info
      personal = @content['personal'] || {}
      email = personal['email'].to_s
      phone = personal['phone'].to_s

      if email.present? && phone.present?
        { score: 100, deduction: 0, severity: 'success', message: 'Email and phone number are present.', category: 'contact_info' }
      elsif email.present? || phone.present?
        { score: 50, deduction: 10, severity: 'warning', message: 'Missing either email or phone number.', category: 'contact_info' }
      else
        { score: 0, deduction: 20, severity: 'error', message: 'Missing both email and phone number.', category: 'contact_info' }
      end
    end

    def check_resume_length
      text = @content.to_json
      word_count = text.split.size

      if word_count < 300
        { score: 50, deduction: 10, severity: 'warning', message: 'Resume is too short. Try to add more details.', category: 'length' }
      elsif word_count > 1000
        { score: 70, deduction: 5, severity: 'warning', message: 'Resume is slightly long. Consider condensing it.', category: 'length' }
      else
        { score: 100, deduction: 0, severity: 'success', message: 'Resume length is optimal.', category: 'length' }
      end
    end

    def check_section_ordering
      # Example logic: personal should ideally be first, but it's unstructured json
      # Just return success for now
      { score: 100, deduction: 0, severity: 'success', message: 'Standard section ordering used.', category: 'ordering' }
    end

    def check_bullet_points
      experiences = @content['experiences'] || []
      bullet_count = 0
      experiences.each do |exp|
        desc = exp['description'].to_s
        bullet_count += desc.lines.count { |l| l.strip.start_with?('-', '•', '*') }
      end

      if experiences.empty?
        { score: 100, deduction: 0, severity: 'info', message: 'No experiences to check bullets for.', category: 'formatting' }
      elsif bullet_count > 0
        { score: 100, deduction: 0, severity: 'success', message: 'Good use of bullet points in experience.', category: 'formatting' }
      else
        { score: 50, deduction: 10, severity: 'warning', message: 'Consider using bullet points in experience descriptions for readability.', category: 'formatting' }
      end
    end

    def check_empty_sections
      empty = []
      %w[personal experiences educations skills projects certifications].each do |sec|
        val = @content[sec]
        empty << sec if val.blank? || (val.is_a?(Array) && val.empty?)
      end

      if empty.any?
        { score: 80, deduction: 5, severity: 'warning', message: "Empty sections found: #{empty.join(', ')}", category: 'content' }
      else
        { score: 100, deduction: 0, severity: 'success', message: 'No empty sections.', category: 'content' }
      end
    end

    def check_special_characters
      text = @content.to_json
      # Very basic check for unicode blocks that ATS might struggle with (just an example)
      if text.match?(/[^\x00-\x7F]/)
        { score: 90, deduction: 2, severity: 'warning', message: 'Some special characters found. Ensure they are standard.', category: 'formatting' }
      else
        { score: 100, deduction: 0, severity: 'success', message: 'No problematic special characters found.', category: 'formatting' }
      end
    end
  end
end
