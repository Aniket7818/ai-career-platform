class ResumeContentNormalizer
  def self.normalize(content)
    return {} unless content.is_a?(Hash)
    
    normalized = {}

    # Personal & Summary
    personal = content['personal'] || content['basics'] || {}
    normalized['personal'] = personal

    summary = content.dig('personal', 'summary') || content['summary'] || content.dig('basics', 'summary')
    normalized['summary'] = summary

    # Experiences
    experiences = content['experiences'] || content['work'] || content['experience'] || []
    normalized['experiences'] = experiences

    # Educations
    educations = content['educations'] || content['education'] || []
    normalized['educations'] = educations

    # Projects
    projects = content['projects'] || []
    normalized['projects'] = projects

    # Skills
    skills_raw = content['skills'] || []
    cleaned_skills = []
    
    if skills_raw.is_a?(Hash)
      # Some resume structures put skills inside a 'skillList' or 'keywords' key
      val = skills_raw['skillList'] || skills_raw['keywords'] || []
      val = val.split(',') if val.is_a?(String)
      cleaned_skills = val.is_a?(Array) ? val : []
    elsif skills_raw.is_a?(Array)
      cleaned_skills = skills_raw
    elsif skills_raw.is_a?(String)
      cleaned_skills = skills_raw.split(',')
    end

    normalized['skills'] = cleaned_skills
      .compact
      .map(&:to_s)
      .map(&:strip)
      .reject(&:empty?)
      .uniq

    # Certifications
    certifications = content['certifications'] || content['certificates'] || []
    normalized['certifications'] = certifications

    normalized
  end
end
