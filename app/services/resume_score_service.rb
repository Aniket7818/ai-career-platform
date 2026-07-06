class ResumeScoreService
  def self.analyze(resume)
    ats_result = ScoreEngine::AtsRuleEngine.new(resume).evaluate
    keyword_result = ScoreEngine::KeywordMatcher.new(resume).evaluate
    completeness_result = ScoreEngine::ContentCompletenessChecker.new(resume).evaluate

    # Configurable weights
    weights = {
      ats: 0.3,
      content: 0.4,
      keywords: 0.3
    }

    # For simplicity, content score here means completeness
    ats_score = ats_result[:score]
    keyword_score = keyword_result[:score]
    completeness_score = completeness_result[:score]
    content_score = completeness_score # Just alias for now

    overall_score = (
      (ats_score * weights[:ats]) +
      (content_score * weights[:content]) +
      (keyword_score * weights[:keywords])
    ).round

    analysis_data = {
      ats: ats_result,
      keywords: keyword_result,
      completeness: completeness_result,
      strengths: generate_strengths(ats_score, content_score, keyword_score),
      weaknesses: generate_weaknesses(ats_score, content_score, keyword_score),
      suggestions: generate_quick_suggestions(ats_result, keyword_result, completeness_result)
    }

    resume.update!(
      last_analysis_score: overall_score,
      ats_score: ats_score,
      keyword_score: keyword_score,
      content_score: content_score,
      completeness_score: completeness_score,
      analysis_version: 1, # Increment if engine logic changes
      last_analyzed_at: Time.current,
      analysis_data: analysis_data
    )

    # If resume versioning is active, also update the latest version score if it's nil
    version = resume.current_version
    version.update!(score_at_creation: overall_score) if version && version.score_at_creation.nil?

    analysis_data.merge(overall_score: overall_score)
  end

  private

  def self.generate_strengths(ats, content, keywords)
    s = []
    s << "Strong ATS formatting" if ats >= 80
    s << "Excellent content completeness" if content >= 80
    s << "Good keyword presence" if keywords >= 80
    s << "Overall solid resume" if s.empty? && (ats + content + keywords) / 3 > 70
    s
  end

  def self.generate_weaknesses(ats, content, keywords)
    w = []
    w << "ATS formatting needs improvement" if ats < 60
    w << "Missing key content sections" if content < 60
    w << "Lacks relevant keywords" if keywords < 60
    w
  end

  def self.generate_quick_suggestions(ats_res, kw_res, comp_res)
    s = []
    
    # Extract some actionable suggestions from the engines
    ats_res[:results].select { |r| r[:severity] == 'error' || r[:severity] == 'warning' }.take(2).each do |r|
      s << r[:message]
    end

    kw_res[:suggestions].take(1).each { |msg| s << msg }

    comp_res[:section_results].each do |sec, data|
      s << data[:reasoning] if data[:status] == 'missing' || data[:status] == 'weak'
      break if s.size >= 5
    end

    s
  end
end
