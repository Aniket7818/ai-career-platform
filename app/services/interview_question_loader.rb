class InterviewQuestionLoader
  def self.load_subject(subject)
    file_path = Rails.root.join("storage", "interview_prep", "#{subject.downcase}.json")
    return [] unless File.exist?(file_path)

    file_content = File.read(file_path)
    parsed = JSON.parse(file_content)

    if parsed.is_a?(Hash) && parsed["questions"]
      parsed["questions"]
    elsif parsed.is_a?(Array)
      parsed
    else
      []
    end
  rescue JSON::ParserError
    []
  end

  def self.available_subjects
    dir_path = Rails.root.join("storage", "interview_prep")
    return [] unless Dir.exist?(dir_path)

    Dir.glob("#{dir_path}/*.json").map do |file|
      subject_name = File.basename(file, ".json")
      questions = load_subject(subject_name)
      {
        subject: subject_name.capitalize,
        slug: subject_name,
        question_count: questions.size
      }
    end
  end
end
