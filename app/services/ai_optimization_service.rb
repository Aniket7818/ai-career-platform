class AiOptimizationService
  class OptimizationError < StandardError; end

  def self.optimize(resume, action, payload = {}, request_meta = {})
    feature = case action
    when "generate_summary" then "resume_summary"
    when "rewrite_experience" then "professional_experience_improvement"
    when "rewrite", "expand", "shorten" then "resume_rewrite"
    when "improve_skills" then "skill_suggestions"
    when "optimize", "tailor_to_job" then "tailor_resume"
    when "generate_cover_letter" then "cover_letter"
    when "generate_linkedin" then "linkedin_optimizer"
    when "ats_booster" then "ats_booster"
    when "translator" then "translator"
    when "achievement_generator" then "achievement_generator"
    when "optimize_project" then "project_optimizer"
    else "resume_rewrite"
    end

    # Issue 3 & 4 & 6: Intelligent stopping and optimization limits
    eligibility = ResumeOptimizationEligibility.check(resume, action)
    if !eligibility[:eligible]
      return { 
        success: false, 
        already_optimized: true, 
        message: eligibility[:message], 
        result: nil, 
        merged_content: resume.content 
      }
    end

    selected_project = nil
    selected_experience = nil

    if action == "optimize_project"
      project_id = payload[:project_id]
      project_action = payload[:project_action] || "complete_optimization"
      project_field = payload[:project_field]

      projects = resume.content["projects"] || []
      if project_id.present?
        selected_project = projects.find { |p| p["id"] == project_id }
        if selected_project.nil? && project_id.to_s =~ /\A\d+\z/
          selected_project = projects[project_id.to_i]
        end
      end
      selected_project ||= projects.first

      if selected_project.nil?
        raise OptimizationError, "Selected project not found in resume."
      end

      title = selected_project["projectName"] || selected_project["name"] || selected_project["title"]
      techs = selected_project["technologies"]
      desc = selected_project["description"]

      if title.blank? && techs.blank?
        raise OptimizationError, "Please enter a project title or technologies first."
      end

      instructions = build_project_prompt(project_action, title, techs, desc, payload[:instructions])
    elsif action == "rewrite_experience"
      experience_id = payload[:experience_id]
      experiences = resume.content["experiences"] || []
      if experience_id.present?
        selected_experience = experiences.find { |e| e["id"] == experience_id }
        if selected_experience.nil? && experience_id.to_s =~ /\A\d+\z/
          selected_experience = experiences[experience_id.to_i]
        end
      end
      selected_experience ||= experiences.first

      if selected_experience.nil?
        raise OptimizationError, "Selected work experience not found in resume."
      end

      instructions = payload[:instructions] || ""
      if payload[:job_description].present?
        instructions += "\n\nTarget Job Description:\n#{payload[:job_description]}"
      end
    else
      raw_instructions = payload[:instructions].to_s.strip

      if ["improve_skills", "ats_booster"].include?(action)
        # Classify intent BEFORE defaulting instructions
        intent = classify_skill_intent(raw_instructions, resume)

        # Smart no-prompt short-circuit: skills exist + section balanced + no prompt
        if intent[:mode] == "already_complete"
          return {
            success: false,
            already_optimized: true,
            message: intent[:guidance_message],
            result: nil,
            merged_content: resume.content
          }
        end

        # Store intent for context building (used later in AiService.generate call)
        payload[:_intent] = intent
        instructions = intent[:effective_instructions]
      else
        instructions = raw_instructions.presence || action
        if payload[:job_description].present?
          instructions += "\n\nTarget Job Description:\n#{payload[:job_description]}"
        end
      end
    end

    parsed = nil
    merged_content = nil
    AiService.generate(
      user: resume.user,
      resume: resume,
      feature: feature,
      context: if action == "optimize_project"
                 { resume_content: selected_project.to_json,
                   target_role: payload[:target_role] || resume.content["target_role"] || "Professional" }
               elsif action == "rewrite_experience"
                 {
                   role:         selected_experience["role"].presence || "(not provided)",
                   company:      selected_experience["company"].presence || "(not provided)",
                   description:  selected_experience["description"].presence || "(empty)",
                   resume_content: "",
                   target_role:  payload[:target_role] || resume.content["target_role"] || "Professional"
                 }
               elsif ["improve_skills", "ats_booster"].include?(action)
                 build_skill_context(resume, instructions, payload)
               elsif ["rewrite", "expand", "shorten"].include?(action)
                 b_text = payload[:bullet_text].to_s.strip
                 if b_text.blank?
                   b_text = get_first_bullet(resume)
                 end
                 {
                   bullet_text: b_text,
                   action_name: action,
                   instructions: payload[:instructions].to_s.strip,
                   word_limit: (payload[:word_limit] || 60).to_s
                 }
               elsif action == "generate_cover_letter"
                 # Extract fields from payload or parse from instructions
                 company_name = payload[:company_name] || payload[:company]
                 hiring_manager = payload[:hiring_manager]
                 tone = payload[:tone]
                 length = payload[:length]
                 job_description = payload[:job_description]

                 raw_instr = instructions.to_s
                 company_name ||= raw_instr.match(/Company:\s*(.*?)\s*\.\s*Hiring Manager:/i)&.captures&.first
                 hiring_manager ||= raw_instr.match(/Hiring Manager:\s*(.*?)\s*\.\s*Tone:/i)&.captures&.first
                 tone ||= raw_instr.match(/Tone:\s*(.*?)\s*\.\s*Length:/i)&.captures&.first
                 length ||= raw_instr.match(/Length:\s*(.*?)\s*\.\s*JD:/i)&.captures&.first
                 job_description ||= raw_instr.match(/JD:\s*(.*)/im)&.captures&.first

                 personal_info = resume.content&.dig("personal") || {}
                 applicant_name = personal_info["name"] || personal_info["firstName"] || resume.user&.full_name || "Applicant"
                 applicant_email = personal_info["email"] || resume.user&.email
                 applicant_phone = personal_info["phone"]
                 applicant_location = personal_info["location"] || personal_info["address"]

                 {
                   resume_content: resume.content.to_json,
                   target_role: payload[:target_role] || resume.content["target_role"] || "Professional",
                   company_name: company_name.presence || "Unknown",
                   hiring_manager: hiring_manager.presence || "Unknown",
                   tone: tone.presence || "Professional",
                   length: length.presence || "Standard",
                   job_description: job_description.presence || "None",
                   applicant_name: applicant_name.presence || "Applicant",
                   applicant_email: applicant_email.presence || "None",
                   applicant_phone: applicant_phone.presence || "None",
                   applicant_location: applicant_location.presence || "None"
                 }
               elsif action == "generate_linkedin"
                 {
                   resume_content: resume.content.to_json,
                   target_role: payload[:target_role] || resume.content["target_role"] || "Professional",
                   industry: payload[:industry] || "Technology"
                 }
               else
                 {
                   resume_content: resume.content.to_json,
                   target_role: payload[:target_role] || resume.content["target_role"] || "Professional"
                 }
               end,
      instructions: instructions,
      force_new: true,
      request_meta: request_meta
    ) do |text|
      quality = AiQualityService.evaluate(text, action, payload)
      unless quality[:passed]
        raise OptimizationError, "AI generated low quality output: #{quality[:reasons].join(', ')}"
      end

      if ["rewrite", "expand", "shorten"].include?(action)
        validate_bullet_response(text)
      end

      parsed = action == "optimize_project" ? parse_project_response(text, project_action) : parse_response(text, action)
      
      if action == "generate_linkedin"
        parsed = validate_and_repair_linkedin(parsed, resume)
      end

      merged_content = compute_update(resume, action, parsed, payload)
    end

    { success: true, message: "Optimization generated successfully. Ready to apply.", result: parsed, merged_content: merged_content }
  rescue OptimizationError => e
    raise e
  rescue AiService::RateLimitError, AiService::TimeoutError, AiService::ProviderUnavailableError, AiService::ApiError, AiService::InvalidRequestError, AiService::DuplicateRequestError, AiService::ConfigurationError, AiService::AuthenticationError, AiService::RequestTooLargeError => e
    raise e
  rescue => e
    Rails.logger.error "AiOptimizationService Error: #{e.message}"
    raise OptimizationError, e.message
  end

  private

  def self.build_project_prompt(project_action, title, technologies, description, user_instructions)
    case project_action
    when "generate_description"
      generate_project_description_prompt(title, technologies, user_instructions)
    when "rewrite_description", "improve_ats", "improve_technical", "improve_verbs", "expand", "shorten", "complete_optimization"
      rewrite_project_description_prompt(project_action, title, technologies, description, user_instructions)
    when "generate_title"
      generate_project_title_prompt(title, technologies, description, user_instructions)
    when "improve_title"
      improve_project_title_prompt(title, technologies, description, user_instructions)
    when "generate_technologies"
      generate_project_technologies_prompt(title, description, user_instructions)
    when "improve_technologies", "technologies_ats_keywords", "technologies_missing_frameworks"
      improve_project_technologies_prompt(project_action, title, technologies, description, user_instructions)
    when "optimize_entire_project"
      optimize_entire_project_prompt(title, technologies, description, user_instructions)
    else
      description.present? ? rewrite_project_description_prompt("rewrite_description", title, technologies, description, user_instructions) : generate_project_description_prompt(title, technologies, user_instructions)
    end
  end

  def self.generate_project_description_prompt(title, technologies, user_instructions)
    prompt = "Generate ONLY the selected project's description as plain text.\n" \
             "Length: 120-180 words.\n" \
             "Use the project title and technologies as context.\n" \
             "Never invent companies, users, downloads, revenue, or metrics.\n" \
             "Do not return markdown, headings, JSON, bullets, explanations, or the full resume.\n" \
             "Project title: #{title.presence || '(Untitled)'}\n" \
             "Technologies: #{technologies.presence || '(None listed)'}"
    append_optional_project_instruction(prompt, user_instructions)
  end

  def self.rewrite_project_description_prompt(project_action, title, technologies, description, user_instructions)
    focus = case project_action
    when "improve_ats" then "Improve ATS keywords naturally."
    when "improve_technical" then "Improve technical depth and implementation details."
    when "improve_verbs" then "Improve action verbs."
    when "expand" then "Expand the description while keeping facts unchanged."
    when "shorten" then "Shorten the description and keep the strongest technical impact."
    when "complete_optimization" then "Improve ATS, grammar, technical depth, action verbs, and implementation details."
    else "Rewrite for ATS, grammar, technical depth, action verbs, and implementation details."
    end

    prompt = "Rewrite ONLY the selected project's description as plain text.\n" \
             "#{focus}\n" \
             "Keep facts unchanged. Never invent companies, users, downloads, revenue, or metrics.\n" \
             "Do not return markdown, headings, JSON, bullets, explanations, or the full resume.\n" \
             "Project title: #{title.presence || '(Untitled)'}\n" \
             "Technologies: #{technologies.presence || '(None listed)'}\n" \
             "Current description: #{description.presence || '(None)'}"
    append_optional_project_instruction(prompt, user_instructions)
  end

  def self.generate_project_title_prompt(title, technologies, description, user_instructions)
    prompt = "Generate ONLY one professional ATS-friendly project title.\n" \
             "Single line. 4-9 words maximum.\n" \
             "No description, markdown, quotes, labels, bullets, URLs, or explanations.\n" \
             "Current title: #{title.presence || '(Untitled)'}\n" \
             "Technologies: #{technologies.presence || '(None listed)'}\n" \
             "Description: #{description.presence || '(None)'}\n" \
             "Example output: Responsive Personal Portfolio Website"
    append_optional_project_instruction(prompt, user_instructions)
  end

  def self.improve_project_title_prompt(title, technologies, description, user_instructions)
    generate_project_title_prompt(title, technologies, description, user_instructions)
  end

  def self.generate_project_technologies_prompt(title, description, user_instructions)
    prompt = "Generate ONLY comma-separated technologies for the selected project.\n" \
             "No sentences, bullets, numbering, markdown, labels, explanations, or URLs.\n" \
             "Project title: #{title.presence || '(Untitled)'}\n" \
             "Description: #{description.presence || '(None)'}\n" \
             "Example output: React.js, Node.js, Express.js, PostgreSQL, Docker, JWT"
    append_optional_project_instruction(prompt, user_instructions)
  end

  def self.improve_project_technologies_prompt(project_action, title, technologies, description, user_instructions)
    focus = case project_action
    when "technologies_ats_keywords" then "Add missing ATS technology keywords."
    when "technologies_missing_frameworks" then "Add likely missing frameworks, libraries, tools, and APIs from the project context."
    else "Improve the list with standard names and missing relevant technologies."
    end

    prompt = "Return ONLY comma-separated technologies for the selected project.\n" \
             "#{focus}\n" \
             "Keep existing technologies unless clearly redundant.\n" \
             "No sentences, bullets, numbering, markdown, labels, explanations, or URLs.\n" \
             "Project title: #{title.presence || '(Untitled)'}\n" \
             "Current technologies: #{technologies.presence || '(None listed)'}\n" \
             "Description: #{description.presence || '(None)'}\n" \
             "Example output: React.js, Node.js, Express.js, PostgreSQL, Docker, JWT"
    append_optional_project_instruction(prompt, user_instructions)
  end

  def self.optimize_entire_project_prompt(title, technologies, description, user_instructions)
    prompt = "Optimize ONLY the selected project.\n" \
             "Return JSON ONLY with exactly these keys: title, technologies, description.\n" \
             "Do not return markdown fences, headings, explanations, or full resume content.\n" \
             "Never touch or generate project links.\n" \
             "Never invent companies, users, downloads, revenue, or metrics.\n" \
             "Current title: #{title.presence || '(Untitled)'}\n" \
             "Current technologies: #{technologies.presence || '(None listed)'}\n" \
             "Current description: #{description.presence || '(None)'}"
    append_optional_project_instruction(prompt, user_instructions)
  end

  def self.append_optional_project_instruction(prompt, user_instructions)
    return prompt if user_instructions.blank?
    "#{prompt}\nOptional user instruction: #{user_instructions}"
  end

  def self.parse_project_response(text, project_action)
    raw = text.to_s.strip

    if project_action == "optimize_entire_project"
      parsed = parse_response(raw, "optimize_project")
      raise OptimizationError, "AI returned invalid project JSON." unless parsed.is_a?(Hash)
      return parsed
    end

    cleaned = strip_ai_wrappers(raw)
    if ["generate_technologies", "improve_technologies", "technologies_ats_keywords", "technologies_missing_frameworks"].include?(project_action)
      return normalize_project_technologies(cleaned)
    end

    if ["generate_title", "improve_title"].include?(project_action)
      return normalize_project_title(cleaned)
    end

    normalize_project_description(cleaned)
  end

  # ─────────────────────────────────────────────────────────────
  # JSON EXTRACTION
  # Strips markdown fences, preamble, and postamble from LLM text.
  # Returns a parsed Hash/Array, or the raw String for cover letters.
  # ─────────────────────────────────────────────────────────────
  def self.parse_response(text, action)
    # 1. Try to pull JSON out of markdown code fences (```json ... ```)
    fenced = text.match(/```(?:json)?\s*(\{.*?\}|\[.*?\])\s*```/m)
    json_str = fenced ? fenced[1] : nil

    # 2. If no fence, find first { or [ and last } or ]
    unless json_str
      first = text.index(/[\{\[]/)
      last  = text.rindex(/[\}\]]/)
      json_str = (first && last && first < last) ? text[first..last] : nil
    end

    if json_str
      sanitized_json = sanitize_json_control_chars(json_str)
      begin
        return JSON.parse(sanitized_json)
      rescue JSON::ParserError => e
        Rails.logger.warn "AiOptimizationService: JSON parse failed — #{e.message}"
        begin
          return JSON.parse(json_str)
        rescue JSON::ParserError
          # Ignore fallback error
        end
      end
    end

    # For cover-letter-style actions, raw text is acceptable
    text
  end

  def self.sanitize_json_control_chars(str)
    return str unless str.is_a?(String)
    
    in_string = false
    escaped = false
    result = ""
    
    str.each_char do |char|
      if escaped
        result << char
        escaped = false
        next
      end
      
      if char == '\\'
        result << char
        escaped = in_string
        next
      end
      
      if char == '"'
        in_string = !in_string
        result << char
        next
      end
      
      if in_string
        case char
        when "\n"
          result << "\\n"
        when "\r"
          result << "\\r"
        when "\t"
          result << "\\t"
        else
          ord = char.ord
          if ord < 32
            result << sprintf("\\u%04x", ord)
          else
            result << char
          end
        end
      else
        result << char
      end
    end
    result
  end


  def self.validate_headline_length(text)
    text.to_s.length <= 220
  end

  def self.validate_about_length(text)
    text.to_s.length <= 2600
  end

  def self.validate_and_repair_linkedin(parsed, resume)
    raise OptimizationError, "Invalid AI response format. Please try again." unless parsed.is_a?(Hash)

    # 1. About Section Validation (Min 300 chars, max 2600 chars)
    about = parsed["about"].to_s.strip
    if about.length < 300 || about.downcase == "coding"
      raise OptimizationError, "The generated LinkedIn About section is too short or incomplete. Please ensure your resume has enough details and try again."
    end

    unless validate_about_length(about)
      about = repair_about(about)
    end
    parsed["about"] = about

    # 2. Headline Options
    headline_options = parsed["headline_options"] || parsed["headlines"]
    unless headline_options.is_a?(Array)
      single_hl = parsed["headline"] || parsed["headlineText"] || "Professional Profile"
      headline_options = [
        { "type" => "ATS Optimized", "text" => single_hl },
        { "type" => "Recruiter Focused", "text" => single_hl },
        { "type" => "Personal Branding", "text" => single_hl },
        { "type" => "Technical", "text" => single_hl },
        { "type" => "Modern & Concise", "text" => single_hl }
      ]
    end

    expected_types = ["ATS Optimized", "Recruiter Focused", "Personal Branding", "Technical", "Modern & Concise"]
    headline_options = headline_options.map.with_index do |opt, idx|
      type = expected_types[idx] || "General"
      text = if opt.is_a?(Hash)
               opt["text"] || opt["headline"] || ""
             else
               opt.to_s
             end
      text = text.strip
      
      # Check validation
      unless validate_headline_length(text)
        text = repair_headline(text)
      end
      { "type" => type, "text" => text }
    end

    # Ensure no duplicates (if any are duplicates, append a distinguishing detail or keyword from the resume)
    texts = headline_options.map { |h| h["text"] }
    if texts.uniq.length < texts.length
      seen = {}
      headline_options.each_with_index do |opt, idx|
        txt = opt["text"]
        if seen[txt]
          suffix = " | #{opt["type"]} Strategy"
          opt["text"] = repair_headline(txt + suffix)
        else
          seen[txt] = true
        end
      end
    end
    parsed["headline_options"] = headline_options
    parsed.delete("headline")

    # 3. Grounding checks to ensure no fabricated skills/technologies
    resume_text = resume.content.to_json
    flat_skills = flatten_skills(resume.content["skills"] || {})

    parsed["top_technologies"] = ground_values(parsed["top_technologies"], resume_text, flat_skills)
    parsed["core_expertise"] = ground_values(parsed["core_expertise"], resume_text, flat_skills)
    parsed["recruiter_keywords"] = ground_values(parsed["recruiter_keywords"], resume_text, flat_skills)
    parsed["networking_topics"] = ground_values(parsed["networking_topics"], resume_text, flat_skills)
    parsed["personal_brand"] = (parsed["personal_brand"] || parsed["personalBrand"]).to_s

    # Inferred Target industries, target roles, and recruiter insights
    parsed["target_industries"] = Array(parsed["target_industries"] || parsed["targetIndustries"]).map(&:to_s).reject(&:empty?)
    parsed["target_roles"] = Array(parsed["target_roles"] || parsed["targetRoles"]).map(&:to_s).reject(&:empty?)

    insights = parsed["insights"] || {}
    unless insights.is_a?(Hash)
      insights = {}
    end

    expected_metrics = [
      "keyword_coverage", "recruiter_visibility", "headline_strength", 
      "technical_depth", "leadership_signals", "business_impact", 
      "achievement_strength", "ats_match", "networking_readiness"
    ]

    repaired_insights = {}
    expected_metrics.each do |metric|
      m_data = insights[metric] || insights[metric.camelize(:lower)] || {}
      score = m_data.is_a?(Hash) ? (m_data["score"] || m_data["points"] || 75).to_i : 75
      reasoning = m_data.is_a?(Hash) ? (m_data["reasoning"] || "Reviewing your profile context for this metric.") : "Reviewing your profile context for this metric."
      suggestion = m_data.is_a?(Hash) ? (m_data["improvement_suggestion"] || m_data["suggestion"] || "Add more details to increase score.") : "Add more details to increase score."
      
      repaired_insights[metric] = {
        "score" => score.clamp(0, 100),
        "reasoning" => reasoning.to_s,
        "improvement_suggestion" => suggestion.to_s
      }
    end
    parsed["insights"] = repaired_insights

    parsed
  end

  def self.ground_values(list, resume_text, fallback_source = [])
    resume_text_down = resume_text.downcase
    grounded = Array(list).map(&:to_s).select do |item|
      item_down = item.downcase.strip
      next false if item_down.empty?
      
      # Direct substring match
      next true if resume_text_down.include?(item_down)
      
      # Handle cases like punctuation/parentheses and partial words
      clean_item = item_down.gsub(/[\(\)\{\}\[\]\-\+\.\,]/, " ").strip
      words = clean_item.split(/\s+/).reject { |w| w.length < 3 }
      
      # If any significant word (length >= 3) matches a word in the resume text, allow it.
      next true if words.any? { |word| resume_text_down.include?(word) }
      
      # Also check if the resume text includes the cleaned version
      next true if resume_text_down.include?(clean_item)
      
      false
    end

    if grounded.empty? && fallback_source.any?
      grounded = fallback_source.map(&:to_s).reject(&:empty?).first(15)
    end
    grounded
  end

  def self.repair_headline(text)
    text = text.strip
    return text if text.length <= 220

    # Shorten intelligently by splitting on separators and keeping elements up to 210 characters
    separators = /[\s]*[|•\-,][\s]*/
    parts = text.split(separators)
    repaired = []
    current_length = 0

    parts.each do |part|
      part_clean = part.strip
      next if part_clean.empty?
      
      if current_length + part_clean.length + (repaired.any? ? 3 : 0) <= 210
        repaired << part_clean
        current_length += part_clean.length + (repaired.size > 1 ? 3 : 0)
      else
        if repaired.empty?
          truncated = part_clean[0..207]
          last_space = truncated.rindex(/\s/)
          if last_space && last_space > 50
            repaired << truncated[0...last_space].strip
          else
            repaired << truncated.strip
          end
        end
        break
      end
    end

    result = repaired.join(" | ")
    if result.length > 220
      truncated = result[0..217]
      last_space = truncated.rindex(/\s/)
      result = last_space && last_space > 50 ? truncated[0...last_space].strip : truncated.strip
    end
    result
  end

  def self.repair_about(text)
    text = text.strip
    return text if text.length <= 2600

    # Repair/Compress logic for About section: keep paragraphs up to 2400 chars.
    paragraphs = text.split(/\n{2,}/)
    repaired_paragraphs = []
    current_length = 0

    paragraphs.each do |para|
      para_clean = para.strip
      next if para_clean.empty?

      if current_length + para_clean.length + (repaired_paragraphs.any? ? 2 : 0) <= 2400
        repaired_paragraphs << para_clean
        current_length += para_clean.length + (repaired_paragraphs.size > 1 ? 2 : 0)
      else
        sentences = para_clean.split(/(?<=[.!?])\s+/)
        repaired_sentences = []
        
        sentences.each do |sent|
          if current_length + sent.length + (repaired_sentences.any? ? 1 : 0) <= 2400
            repaired_sentences << sent
            current_length += sent.length + (repaired_sentences.size > 1 ? 1 : 0)
          else
            break
          end
        end
        
        if repaired_sentences.any?
          repaired_paragraphs << repaired_sentences.join(" ")
        end
        break
      end
    end

    result = repaired_paragraphs.join("\n\n")
    if result.length > 2600
      truncated = result[0..2597]
      last_space = truncated.rindex(/\s/)
      result = last_space && last_space > 1000 ? truncated[0...last_space].strip : truncated.strip
    end
    result
  end

  # ─────────────────────────────────────────────────────────────
  # FIELD NORMALISATION HELPERS
  # The LLM often uses different key names than the frontend form.
  # These helpers translate AI output into the exact structure the
  # frontend expects, so each section renders correctly.
  # ─────────────────────────────────────────────────────────────

  # Normalise a single experience object from AI output.
  # Frontend ExperienceSection.vue uses: role, company, startDate, endDate, description
  def self.normalise_experience(exp)
    return exp unless exp.is_a?(Hash)
    {
      "id"          => exp["id"] || SecureRandom.uuid,
      "role"        => exp["role"] || exp["title"] || exp["jobTitle"] || exp["position"] || "",
      "company"     => exp["company"] || exp["employer"] || exp["organization"] || "",
      "startDate"   => normalise_date(exp["startDate"] || exp["start_date"] || exp["from"]),
      "endDate"     => normalise_date(exp["endDate"] || exp["end_date"] || exp["to"]),
      "description" => normalise_description(exp),
    }
  end

  # Normalise a single education object.
  # Frontend EducationSection.vue uses: school, degree, startDate, endDate, cgpa
  def self.normalise_education(edu)
    return edu unless edu.is_a?(Hash)
    {
      "id"        => edu["id"] || SecureRandom.uuid,
      "school"    => edu["school"] || edu["institution"] || edu["university"] || edu["college"] || "",
      "degree"    => edu["degree"] || edu["qualification"] || "",
      "startDate" => normalise_date(edu["startDate"] || edu["start_date"] || edu["from"]),
      "endDate"   => normalise_date(edu["endDate"] || edu["end_date"] || edu["to"]),
      "cgpa"      => edu["cgpa"] || edu["gpa"] || edu["grade"] || "",
    }
  end

  # Normalise a single project object.
  # Frontend ProjectsSection.vue uses: projectName, projectLink, technologies, description
  def self.normalise_project(proj)
    return proj unless proj.is_a?(Hash)
    tech = proj["technologies"]
    tech = tech.is_a?(Array) ? tech.join(", ") : tech.to_s
    {
      "id"          => proj["id"] || SecureRandom.uuid,
      "projectName" => proj["projectName"] || proj["name"] || proj["title"] || "",
      "projectLink" => proj["projectLink"] || proj["link"] || proj["url"] || proj["github"] || "",
      "technologies"=> tech,
      "description" => normalise_description(proj),
    }
  end

  # Normalise a single certification object.
  # Frontend CertificationsSection.vue uses: certName, issuingOrg, issueDate, credentialUrl
  def self.normalise_certification(cert)
    return cert unless cert.is_a?(Hash)
    {
      "id"           => cert["id"] || SecureRandom.uuid,
      "certName"     => cert["certName"] || cert["name"] || cert["title"] || "",
      "issuingOrg"   => cert["issuingOrg"] || cert["issuer"] || cert["organization"] || cert["issuing_org"] || "",
      "issueDate"    => normalise_date(cert["issueDate"] || cert["issue_date"] || cert["date"]),
      "credentialUrl"=> cert["credentialUrl"] || cert["url"] || cert["link"] || "",
    }
  end

  # Merge description + bulletPoints into a single readable string.
  # Handles array of strings (Issue 1) and raw arrays cleanly.
  def self.normalise_description(obj)
    return "" if obj.blank?

    if obj.is_a?(Array)
      bullets = obj.map do |item|
        str = item.to_s.strip
        str = str.sub(/\A[•\-\*\s]+/, '')
        str = str.sub(/\A\d+[\.\)\s]+/, '')
        "• #{str.strip}"
      end
      return bullets.join("\n")
    end

    if obj.is_a?(String)
      str = obj.strip
      if !str.include?("\n")
        bullet_regex = /\s*[•●▪◦■◆★]\s*|\s+[-\*]\s+/
        if str.scan(bullet_regex).size > 0
          parts = str.split(bullet_regex).map(&:strip).reject(&:empty?)
          if parts.size > 1
            return parts.map { |p| "• #{p}" }.join("\n")
          end
        end
      end
      return str
    end

    return "" unless obj.is_a?(Hash)

    desc = obj["description"]
    bullets = obj["bulletPoints"] || obj["bullets"]
    
    parts = []
    if desc.present?
      if desc.is_a?(Array)
        parts << normalise_description(desc)
      else
        parts << desc.to_s.strip
      end
    end

    if bullets.is_a?(Array) && bullets.any?
      parts += bullets.map do |b|
        str = b.to_s.strip
        str = str.sub(/\A[•\-\*\s]+/, '')
        str = str.sub(/\A\d+[\.\)\s]+/, '')
        "• #{str.strip}"
      end
    elsif bullets.present?
      parts << bullets.to_s.strip
    end

    parts.join("\n")
  end

  # Normalise date strings — keep YYYY-MM format, strip full ISO timestamps.
  def self.normalise_date(val)
    return "" unless val.present?
    val.to_s.match(/(\d{4}-\d{2})/) ? $1 : val.to_s
  end

  # Flatten a skills value into a list of strings
  # Handles Example A, B, and C formats (Issue 3)
  def self.flatten_skills(skills_val)
    case skills_val
    when Array
      skills_val.map do |item|
        if item.is_a?(Hash)
          item["skill"] || item["name"] || item["title"] || item.values.first
        else
          item.to_s
        end
      end.map(&:to_s).map(&:strip).reject(&:empty?)
    when Hash
      if skills_val["skillList"].present?
        flatten_skills(skills_val["skillList"])
      elsif skills_val["skills"].present?
        flatten_skills(skills_val["skills"])
      elsif skills_val["list"].present?
        flatten_skills(skills_val["list"])
      else
        flatten_skills(skills_val.values.flatten)
      end
    else
      skills_val.to_s.split(",").map(&:strip).reject(&:empty?)
    end
  end

  def self.normalize_project_title(value)
    value.to_s
         .gsub(/```(?:json)?|```/, "")
         .split(/\r?\n/)
         .map { |line| line.gsub(/\A(?:project\s*title|title)\s*:\s*/i, "").strip }
         .reject(&:blank?)
         .first
         .to_s
         .gsub(/\A["'•\-\s]+|["'\s]+\z/, "")
  end

  def self.normalize_project_technologies(value)
    raw = value.to_s
               .gsub(/\A(?:technologies|tech stack|skills)\s*:\s*/i, "")
               .gsub(/[•\-\*]\s*/, ", ")
               .gsub(/\r?\n+/, ", ")

    raw.split(",")
       .map { |item| item.gsub(/\A(?:and|with)\s+/i, "").strip }
       .reject(&:blank?)
       .uniq
       .join(", ")
  end

  def self.strip_ai_wrappers(value)
    value.to_s
         .gsub(/```(?:json|text)?/i, "")
         .gsub(/```/, "")
         .gsub(/\A(?:answer|output|result)\s*:\s*/i, "")
         .strip
  end

  def self.normalize_project_description(value)
    text = strip_ai_wrappers(value)
    text = text.gsub(/\A(?:project\s*description|description)\s*:\s*/i, "").strip

    forbidden_headings = /\b(summary|education|experience|skills|certifications|languages|achievements|interests)\b\s*:/i
    if text.match?(forbidden_headings) || text.match?(/\A[A-Z][a-z]+(?:\s+[A-Z][a-z]+)?\s*\n+(summary|education|experience|skills|projects)\b/i)
      raise OptimizationError, "AI returned full resume content instead of a project-only description. Please try again."
    end

    text
  end

  def self.compute_update(resume, action, parsed, payload)
    original = resume.content ? resume.content.deep_dup.deep_stringify_keys : {}
    content = resume.content ? resume.content.deep_dup.deep_stringify_keys : {}

    # Temporary debug logging: Original values
    Rails.logger.info "[AI_PIPELINE_DEBUG] --- START COMPUTE_UPDATE (Action: #{action}) ---"
    Rails.logger.info "[AI_PIPELINE_DEBUG] Original Headline: #{original.dig('personal', 'headline').inspect}"
    if original["experiences"].is_a?(Array)
      original["experiences"].each_with_index do |exp, idx|
        Rails.logger.info "[AI_PIPELINE_DEBUG] Original Experience[#{idx}] Role: #{exp['role'].inspect} (ID: #{exp['id']})"
      end
    end
    if original["projects"].is_a?(Array)
      original["projects"].each_with_index do |proj, idx|
        Rails.logger.info "[AI_PIPELINE_DEBUG] Original Project[#{idx}] Name: #{proj['projectName'].inspect} (ID: #{proj['id']})"
      end
    end
    Rails.logger.info "[AI_PIPELINE_DEBUG] Original Education: #{original['educations'].inspect}"
    Rails.logger.info "[AI_PIPELINE_DEBUG] Original Certifications: #{original['certifications'].inspect}"
    Rails.logger.info "[AI_PIPELINE_DEBUG] AI proposed value (raw parsed): #{parsed.inspect}"

    if parsed.is_a?(Hash)
      parsed = parsed.deep_stringify_keys
    elsif parsed.is_a?(Array)
      parsed = parsed.map { |item| item.is_a?(Hash) ? item.deep_stringify_keys : item }
    end

    unless parsed.is_a?(Hash) || parsed.is_a?(Array) || ["generate_cover_letter", "generate_linkedin", "translator", "optimize_project", "rewrite_experience", "generate_summary", "improve_skills", "ats_booster", "rewrite", "expand", "shorten", "achievement_generator"].include?(action)
      raise OptimizationError, "Invalid AI response format. Expected structured JSON data, got: #{parsed.class}"
    end

    case action
    # ── Optimize Project description only ─────────────────────────
    when "optimize_project"
      project_id = payload[:project_id]
      project_action = payload[:project_action]
      project_field = payload[:project_field]
      projects = content["projects"] || []
      
      idx = if project_id.present?
        projects.find_index { |p| p["id"] == project_id }
      end
      idx ||= if project_id.to_s =~ /\A\d+\z/
        project_id.to_i
      end
      idx ||= 0

      if projects[idx]
        result_text = parsed.to_s.strip.gsub(/\A["']|["']\z/, "")

        if project_action == "generate_title" || project_field == "title"
          projects[idx]["projectName"] = normalize_project_title(result_text)
        elsif ["generate_technologies", "improve_technologies", "technologies_ats_keywords", "technologies_missing_frameworks"].include?(project_action) || project_field == "technologies"
          projects[idx]["technologies"] = normalize_project_technologies(result_text)
        elsif project_action == "optimize_entire_project" || project_field == "entire_project"
          project_data = parsed.is_a?(Hash) ? parsed : {}
          next_title = project_data["title"] || project_data["projectName"]
          projects[idx]["projectName"] = normalize_project_title(next_title.to_s) if next_title.present?
          projects[idx]["technologies"] = normalize_project_technologies(project_data["technologies"].to_s) if project_data["technologies"].present?
          projects[idx]["description"] = normalize_project_description(project_data["description"].to_s) if project_data["description"].present?
        else
          projects[idx]["description"] = normalize_project_description(result_text)
        end
      end
      content["projects"] = projects

    # ── Generate / rewrite summary only ──────────────────────────
    when "generate_summary"
      content["personal"] ||= {}
      summary = parsed.is_a?(Hash) ? (parsed["summary"] || parsed["professionalSummary"] || parsed["objective"]) : nil
      content["personal"]["summary"] = summary.present? ? summary.to_s : parsed.to_s

    # ── Rewrite experience only (description field ONLY) ────────
    when "rewrite_experience"
      experience_id = payload[:experience_id]
      experiences = content["experiences"] || []

      idx = experiences.find_index { |e| e["id"] == experience_id } if experience_id.present?
      idx ||= experience_id.to_s =~ /\A\d+\z/ ? experience_id.to_i : nil
      idx ||= 0

      if experiences[idx]
        # Extract description text regardless of whether AI returned JSON or plain text
        new_description = if parsed.is_a?(Hash)
          normalise_description(parsed)
        elsif parsed.is_a?(Array)
          parsed.map.with_index { |item, i| "#{i > 0 ? "\n" : ""}#{item}" }.join
        else
          parsed.to_s.strip
        end
        experiences[idx]["description"] = new_description if new_description.present?
      end
      content["experiences"] = experiences

    # ── Bullet-level experience rewrites (rewrite / expand / shorten) ────────
    when "rewrite", "expand", "shorten"
      experience_id = payload[:experience_id]
      experiences = content["experiences"] || []

      idx = experiences.find_index { |e| e["id"] == experience_id } if experience_id.present?
      idx ||= experience_id.to_s =~ /\A\d+\z/ ? experience_id.to_i : nil
      idx ||= 0

      if experiences[idx]
        original_desc = experiences[idx]["description"].to_s
        bullets = original_desc.split(/\r?\n/)
        
        # Check if the description has no newlines but has inline bullets, let's split it!
        if !original_desc.include?("\n")
          bullet_regex = /\s*[•●▪◦■◆★]\s*|\s+[-\*]\s+/
          if original_desc.scan(bullet_regex).size > 0
            bullets = original_desc.split(bullet_regex).map(&:strip).reject(&:empty?)
          end
        end

        target_bullet_normalized = normalize_bullet_for_comparison(payload[:bullet_text])
        
        # Find the index of the matching bullet
        match_idx = bullets.find_index do |b|
          normalize_bullet_for_comparison(b) == target_bullet_normalized
        end
        
        if match_idx
          # Replace only that bullet. Keep the leading bullet style if present in the original bullet!
          original_bullet = bullets[match_idx]
          bullet_prefix = original_bullet.match(/\A\s*([-*•●▪◦■◆★+]\s*)/)&.captures&.first || ""
          
          # Ensure the new bullet doesn't get double prefix
          new_bullet_content = parsed.to_s.strip.gsub(/\A\s*[-*•●▪◦■◆★+]\s*/, "")
          bullets[match_idx] = "#{bullet_prefix}#{new_bullet_content}"
          experiences[idx]["description"] = bullets.map { |b| b.match?(/\A\s*[-*•●▪◦■◆★+]/) ? b : "• #{b}" }.join("\n")
        else
          # If not found, replace the first bullet or fallback
          if bullets.empty?
            experiences[idx]["description"] = parsed.to_s.strip
          else
            original_bullet = bullets[0]
            bullet_prefix = original_bullet.match(/\A\s*([-*•●▪◦■◆★+]\s*)/)&.captures&.first || ""
            new_bullet_content = parsed.to_s.strip.gsub(/\A\s*[-*•●▪◦■◆★+]\s*/, "")
            bullets[0] = "#{bullet_prefix}#{new_bullet_content}"
            experiences[idx]["description"] = bullets.map { |b| b.match?(/\A\s*[-*•●▪◦■◆★+]/) ? b : "• #{b}" }.join("\n")
          end
        end
      end
      content["experiences"] = experiences

    # ── Achievement generator ─────────────────────────────────────────────────
    when "achievement_generator"
      raw_exp = if parsed.is_a?(Hash)
        parsed["workExperience"] || parsed["experience"] || parsed["work"] || parsed["experiences"]
      elsif parsed.is_a?(Array)
        parsed
      end

      if raw_exp.is_a?(Array)
        content["experiences"] = raw_exp.map { |e| normalise_experience(e) }
      else
        experience_id = payload[:experience_id]
        experiences = content["experiences"] || []

        idx = experiences.find_index { |e| e["id"] == experience_id } if experience_id.present?
        idx ||= experience_id.to_s =~ /\A\d+\z/ ? experience_id.to_i : nil
        idx ||= 0

        if experiences[idx]
          if parsed.is_a?(Hash)
            experiences[idx]["role"] = parsed["role"] || parsed["title"] if parsed["role"].present? || parsed["title"].present?
            experiences[idx]["company"] = parsed["company"] || parsed["employer"] if parsed["company"].present? || parsed["employer"].present?
            experiences[idx]["description"] = normalise_description(parsed)
          else
            experiences[idx]["description"] = parsed.to_s.strip
          end
        end
        content["experiences"] = experiences
      end

    # ── ATS keyword booster / improve skills ────────────────────
    when "improve_skills", "ats_booster"
      existing = flatten_skills(content["skills"]).map(&:strip).reject(&:empty?)
      new_kws  = flatten_skills(parsed.is_a?(Hash) ? (parsed["skills"] || parsed["keywords"] || parsed) : parsed)
                   .map(&:strip)
                   .reject(&:empty?)

      # Case-insensitive deduplication — also strip surrounding punctuation from AI output
      existing_normalized = existing.map { |s| s.downcase.gsub(/[^a-z0-9\s]/, "").strip }
      filtered_new_kws = new_kws.reject do |kw|
        kw_norm = kw.downcase.gsub(/[^a-z0-9\s]/, "").strip
        existing_normalized.include?(kw_norm)
      end

      content["skills"] ||= {}
      content["skills"]["skillList"] = (existing + filtered_new_kws).join(", ")

    # ── Cover letter / LinkedIn — never touch resume ─────────────
    when "generate_cover_letter", "generate_linkedin", "translator"
      # Intentionally empty – do NOT modify resume content

    # ── Full tailor (default optimization path) ──────────────────
    when "optimize", "tailor_to_job"
      if parsed.is_a?(Hash)
        # Summary
        summary = parsed["summary"] || parsed["professionalSummary"] || parsed["objective"]
        if summary.present?
          content["personal"] ||= {}
          content["personal"]["summary"] = summary.to_s
        end

        # Experience → content["experiences"]
        raw_exp = parsed["workExperience"] || parsed["experience"] || parsed["work"] || parsed["experiences"]
        if raw_exp.is_a?(Array) && raw_exp.any?
          content["experiences"] = raw_exp.map { |e| normalise_experience(e) }
        end

        # Projects → content["projects"]
        raw_proj = parsed["projects"]
        if raw_proj.is_a?(Array) && raw_proj.any?
          content["projects"] = raw_proj.map { |p| normalise_project(p) }
        end

        # Education → content["educations"]
        raw_edu = parsed["education"] || parsed["educations"]
        if raw_edu.is_a?(Array) && raw_edu.any?
          content["educations"] = raw_edu.map { |e| normalise_education(e) }
        end

        # Certifications → content["certifications"]
        raw_cert = parsed["certifications"]
        if raw_cert.is_a?(Array) && raw_cert.any?
          content["certifications"] = raw_cert.map { |c| normalise_certification(c) }
        end

        # Skills → content["skills"]["skillList"]
        if parsed["skills"].present?
          content["skills"] ||= {}
          existing = content["skills"]["skillList"].to_s.split(",").map(&:strip).reject(&:empty?)
          new_kws  = flatten_skills(parsed["skills"])
          content["skills"]["skillList"] = (existing + new_kws).uniq.join(", ")
        end
      end
    end

    # Enforce type-safety validation and repair schema format
    content = repair_schema_types(content)

    # Restore immutable fields to protect factual info (Issue 4, 8)
    content = restore_immutable_fields(content, original, action, payload)

    # Temporary debug logging: Repaired values
    Rails.logger.info "[AI_PIPELINE_DEBUG] Repaired Headline: #{content.dig('personal', 'headline').inspect}"
    if content["experiences"].is_a?(Array)
      content["experiences"].each_with_index do |exp, idx|
        Rails.logger.info "[AI_PIPELINE_DEBUG] Repaired Experience[#{idx}] Role: #{exp['role'].inspect} (ID: #{exp['id']})"
      end
    end
    if content["projects"].is_a?(Array)
      content["projects"].each_with_index do |proj, idx|
        Rails.logger.info "[AI_PIPELINE_DEBUG] Repaired Project[#{idx}] Name: #{proj['projectName'].inspect} (ID: #{proj['id']})"
      end
    end
    Rails.logger.info "[AI_PIPELINE_DEBUG] Repaired Education: #{content['educations'].inspect}"
    Rails.logger.info "[AI_PIPELINE_DEBUG] Repaired Certifications: #{content['certifications'].inspect}"
    Rails.logger.info "[AI_PIPELINE_DEBUG] --- END COMPUTE_UPDATE ---"

    content
  end

  def self.generate_label(action)
    case action
    when "optimize_project" then "Optimized Project"
    when "generate_summary" then "Generated Summary"
    when "rewrite_experience", "rewrite" then "Rewrote Experience"
    when "expand" then "Expanded Bullets"
    when "shorten" then "Shortened Bullets"
    when "improve_skills" then "Improved Skills"
    when "optimize", "tailor_to_job" then "Tailored to Job"
    when "generate_cover_letter" then "Generated Cover Letter"
    when "generate_linkedin" then "Generated LinkedIn Profile"
    when "ats_booster" then "Added ATS Keywords"
    when "translator" then "Translated Resume"
    when "achievement_generator" then "Generated Achievements"
    else "AI Optimization"
    end
  end

  # ─────────────────────────────────────────────────────────────
  # SKILL INTENT CLASSIFICATION
  # Parses the user's instruction to detect category, quantity,
  # and generation mode BEFORE calling the LLM.
  # ─────────────────────────────────────────────────────────────

  # Category keyword map — each entry lists synonyms that map to a canonical name.
  SKILL_CATEGORY_MAP = {
    "Testing"            => %w[test testing jest mocha chai cypress playwright jasmine rspec unittest spec e2e tdd bdd],
    "Database"           => %w[database db databases sql mysql postgresql mongo mongodb redis sqlite nosql orm],
    "Frontend"           => %w[frontend front-end ui react vue angular svelte nextjs html css tailwind jquery],
    "Backend"            => %w[backend back-end server nodejs node express rails django fastapi flask spring],
    "Cloud"              => %w[cloud aws azure gcp google-cloud heroku digitalocean cloudflare vercel netlify],
    "DevOps"             => %w[devops ci cd docker kubernetes terraform ansible jenkins github-actions circleci],
    "Security"           => %w[security auth authentication authorization jwt oauth saml ssl tls owasp],
    "Version Control"    => %w[git github gitlab bitbucket version-control vcs svn],
    "Mobile"             => %w[mobile android ios swift kotlin react-native flutter xamarin],
    "Programming Language" => %w[language languages python ruby java go rust c++ c# kotlin typescript javascript php],
    "Soft Skill"         => %w[soft leadership communication teamwork management agile scrum project-management],
    "Architecture"       => %w[architecture microservices api rest graphql soap event-driven domain-driven],
    "API"                => %w[api rest graphql grpc websocket webhook openapi swagger postman],
    "CI/CD"              => %w[cicd ci-cd pipeline jenkins github-actions gitlab-ci circleci travis],
    "Message Queue"      => %w[queue kafka rabbitmq celery sidekiq pubsub messaging],
    "Data/ML"            => %w[data machine-learning ml ai pandas numpy scikit tensorflow pytorch jupyter],
    "Operating System"   => %w[linux unix windows macos bash shell powershell],
  }.freeze

  def self.classify_skill_intent(raw_instructions, resume)
    instruction = raw_instructions.to_s.strip.downcase
    is_blank = instruction.blank? || instruction.length < 3

    existing_skills = flatten_skills(resume.content["skills"] || {}).reject(&:empty?)
    missing_cats = resume.analysis_data&.dig("completeness", "section_results", "skills", "missing_categories") || []

    # ── MODE 1: Foundation — empty section, no prompt ──────────────────────
    if existing_skills.empty? && is_blank
      return {
        mode: "foundation",
        detected_category: nil,
        detected_quantity: "10-12",
        effective_instructions: "Generate a balanced foundation of 10-12 skills for this role covering major categories: Programming Languages, Frontend/Backend, Database, Version Control, and relevant tools.",
        guidance_message: nil
      }
    end

    # ── MODE 2: Explicit instruction — user typed something ─────────────────
    unless is_blank
      detected_cat = detect_category(instruction)
      detected_qty = extract_quantity(instruction)

      # Build an explicit, structured instruction for the LLM
      effective = build_explicit_instruction(instruction, detected_cat, detected_qty, existing_skills)

      return {
        mode: "explicit",
        detected_category: detected_cat,
        detected_quantity: detected_qty,
        effective_instructions: effective,
        guidance_message: nil
      }
    end

    # ── MODE 3: Existing skills + no prompt ─────────────────────────────────
    if existing_skills.any?
      skill_count = existing_skills.length

      # If section is clearly well-rounded, short-circuit and guide the user
      if skill_count >= 12 && missing_cats.empty?
        return {
          mode: "already_complete",
          detected_category: nil,
          detected_quantity: nil,
          effective_instructions: nil,
          guidance_message: "Your skills section already has a strong foundation (#{skill_count} skills detected). " \
            "Tell AI what you'd like to generate:\n\n" \
            "• Generate one testing framework\n" \
            "• Add 2 databases\n" \
            "• Add missing ATS skills\n" \
            "• Generate 3 DevOps tools"
        }
      end

      # Gap-fill mode: generate only missing categories
      effective = if missing_cats.any?
        "Generate 3-5 skills to fill these missing ATS categories: #{missing_cats.join(', ')}. Do not generate any skill that already exists."
      else
        "Analyze the existing skills and generate 3-5 skills that are most commonly missing for this role. Do not generate any skill that already exists."
      end

      return {
        mode: "gap_fill",
        detected_category: missing_cats.first,
        detected_quantity: "3-5",
        effective_instructions: effective,
        guidance_message: nil
      }
    end

    # Fallback
    {
      mode: "gap_fill",
      detected_category: nil,
      detected_quantity: "4-5",
      effective_instructions: "Generate 4-5 relevant skills for this role.",
      guidance_message: nil
    }
  end

  # Detect which category the user is asking about from the instruction text
  def self.detect_category(instruction)
    return nil if instruction.blank?

    words = instruction.downcase.split(/[\s,\-\/]+/)
    SKILL_CATEGORY_MAP.each do |category, keywords|
      return category if keywords.any? { |kw| words.any? { |w| w.include?(kw) || kw.include?(w) } }
    end
    nil
  end

  # Extract an explicit numeric quantity from the instruction
  def self.extract_quantity(instruction)
    return nil if instruction.blank?

    # Match written numbers first: "one", "two", "three", etc.
    word_nums = { "one" => "1", "two" => "2", "three" => "3", "four" => "4", "five" => "5",
                  "six" => "6", "seven" => "7", "eight" => "8", "nine" => "9", "ten" => "10" }
    word_nums.each do |word, num|
      return num if instruction.match?(/\b#{word}\b/i)
    end

    # Then numeric: "1", "2", "5", etc.
    m = instruction.match(/\b(\d+)\b/)
    return m[1] if m

    # "some", "a few", "several" → 4-5
    return "4-5" if instruction.match?(/\b(some|a few|several|few)\b/i)

    nil
  end

  # Build a precise, structured instruction string from parsed intent
  def self.build_explicit_instruction(raw, category, quantity, existing_skills)
    parts = ["You MUST follow these constraints strictly:"]
    parts << "- Generate ONLY #{quantity} skill(s). Not more, not less." if quantity.present?
    parts << "- Generate ONLY skills from the '#{category}' category. Do not generate anything outside this category." if category.present?
    if existing_skills.any?
      parts << "- NEVER generate any of these existing skills: #{existing_skills.join(', ')}"
    end
    parts << "- User's original request: \"#{raw}\""
    parts.join("\n")
  end

  # Build the full context hash for the skill_suggestions prompt template
  def self.build_skill_context(resume, instructions, payload)
    intent = payload[:_intent] || {}
    existing = flatten_skills(resume.content["skills"] || {}).map(&:strip).reject(&:empty?)
    missing_cats = resume.analysis_data&.dig("completeness", "section_results", "skills", "missing_categories") || []

    # Only send a compact resume summary — NOT the full JSON blob.
    # This is the single most important fix: the LLM must not see raw tech
    # from project/experience sections or it will re-list those instead of
    # generating what the user actually asked for.
    personal = resume.content["personal"] || {}
    resume_summary = []
    resume_summary << "Target Role: #{payload[:target_role] || resume.content['target_role'] || 'Professional'}"
    resume_summary << "Headline: #{personal['headline']}" if personal["headline"].present?
    resume_summary << "Name: #{personal['fullName']}" if personal["fullName"].present?
    # Only include the first experience title/company for role context (no tech lists)
    first_exp = (resume.content["experiences"] || []).first
    resume_summary << "Most Recent Role: #{first_exp['role']} at #{first_exp['company']}" if first_exp

    {
      resume_content: resume_summary.join("\n"),
      target_role: payload[:target_role] || resume.content["target_role"] || "Professional",
      # Pre-join arrays to strings — PromptLibrary renders via <%= key %> as .to_s
      current_skills: existing.join(", "),
      missing_categories: missing_cats.join(", "),
      detected_category: intent[:detected_category].to_s,
      detected_quantity: intent[:detected_quantity].to_s,
      generation_mode: intent[:mode] || "gap_fill"
    }
  end

  def self.blank_object?(hash, exclude_keys = ["id"])
    return true unless hash.is_a?(Hash)
    hash.except(*exclude_keys).values.all? { |v| v.blank? || (v.is_a?(Array) && v.all?(&:blank?)) }
  end

  def self.sanitize_text_integrity(text, original_text)
    return "" if text.blank?
    original_text ||= ""
    
    # Split text and original_text into lines to preserve layout (newlines/bullets)
    lines = text.to_s.split(/\r?\n/)
    
    # Normalize original text for word lookup
    original_words = original_text.downcase.scan(/\b[a-z0-9']+\b/).to_set
    original_numbers = original_text.scan(/\b\d+\b/).to_set

    # List of seniority/hype keywords to protect (Issue 2)
    protected_words = {
      "senior" => "",
      "lead" => "",
      "principal" => "",
      "staff" => "",
      "architect" => "",
      "manager" => "",
      "expert" => "",
      "director" => "",
      "head" => "",
      "vice president" => ""
    }

    # Hype phrase replacements if not in original (Issue 3)
    hype_phrases = {
      "highly experienced" => "experienced",
      "expert in" => "proficient in",
      "industry veteran" => "professional",
      "proven track record" => "",
      "proven track record of" => "",
      "leadership experience" => "experience",
      "award-winning" => "",
      "10\\+ years" => "",
      "years of experience" => "experience"
    }

    sanitized_lines = lines.map do |line|
      l = line.dup

      # If the original text does NOT contain the keyword, replace it in the new text
      protected_words.each do |kw, replacement|
        next if original_words.include?(kw)
        l = l.gsub(/\b#{Regexp.escape(kw)}\b/i, replacement)
      end

      hype_phrases.each do |phrase, replacement|
        next if original_text.downcase.include?(phrase.gsub("\\", ""))
        l = l.gsub(/\b#{phrase}\b/i, replacement)
      end

      # Metric / Number fabrication filter (detect percentages like 50%) (Issue 7)
      l = l.gsub(/(\b\d+%(?!\w))/) do |match|
        num = match.scan(/\d+/).first
        if original_numbers.include?(num) || original_text.include?(match)
          match
        else
          "significant"
        end
      end

      # Metric / Number fabrication filter (detect currencies like $10M, 10M, $100k) (Issue 7)
      l = l.gsub(/(\$\d+(?:\.\d+)?[KMB]?|\b\d+[KMB]\b)/i) do |match|
        num = match.scan(/\d+/).first
        if original_numbers.include?(num) || original_text.include?(match)
          match
        else
          "substantial"
        end
      end

      # Scan for other lone numbers (2 or more digits, excluding years like 2022, 2023, etc., or standard dates) (Issue 7)
      l = l.gsub(/(?<![\$\d])\b(\d{2,})\b(?!\s*%)/) do |match|
        if match.match?(/\A(?:19|20)\d{2}\z/) || original_numbers.include?(match)
          match
        else
          ""
        end
      end

      # Clean up double spaces, punctuation, weird lists within the line (but NOT newlines!)
      l = l.gsub(/[ \t]+/, " ").gsub(/\s*,\s*,/, ",").gsub(/\s*\.\s*\./, ".").strip
      l = l.gsub(/•\s*•/, "•").gsub(/•\s*\z/, "").strip
      l
    end

    sanitized_lines.join("\n")
  end

  def self.repair_schema_types(content)
    content ||= {}
    content = content.is_a?(Hash) ? content.deep_stringify_keys : {}

    # Personal
    content["personal"] = content["personal"].is_a?(Hash) ? content["personal"] : {}
    content["personal"]["summary"] = content["personal"]["summary"].is_a?(Array) ? normalise_description(content["personal"]["summary"]) : content["personal"]["summary"].to_s
    content["personal"]["headline"] = content["personal"]["headline"].to_s if content["personal"]["headline"].present?

    # Experiences
    exps = content["experiences"]
    if exps.is_a?(Array)
      content["experiences"] = exps.map do |exp|
        next nil unless exp.is_a?(Hash)
        exp = exp.deep_stringify_keys
        next nil if blank_object?(exp)
        exp["id"] ||= SecureRandom.uuid
        exp["role"] = exp["role"].to_s
        exp["company"] = exp["company"].to_s
        exp["startDate"] = normalise_date(exp["startDate"])
        exp["endDate"] = normalise_date(exp["endDate"])
        exp["description"] = normalise_description(exp["description"])
        if exp["bulletPoints"].present?
          exp["bulletPoints"] = Array(exp["bulletPoints"]).map(&:to_s).reject(&:blank?)
        end
        exp
      end.compact
    else
      content["experiences"] = []
    end

    # Educations
    edus = content["educations"]
    if edus.is_a?(Array)
      content["educations"] = edus.map do |edu|
        next nil unless edu.is_a?(Hash)
        edu = edu.deep_stringify_keys
        next nil if blank_object?(edu)
        edu["id"] ||= SecureRandom.uuid
        edu["school"] = edu["school"].to_s
        edu["degree"] = edu["degree"].to_s
        edu["startDate"] = normalise_date(edu["startDate"])
        edu["endDate"] = normalise_date(edu["endDate"])
        edu["cgpa"] = edu["cgpa"].to_s
        edu
      end.compact
    else
      content["educations"] = []
    end

    # Projects
    projs = content["projects"]
    if projs.is_a?(Array)
      content["projects"] = projs.map do |proj|
        next nil unless proj.is_a?(Hash)
        proj = proj.deep_stringify_keys
        next nil if blank_object?(proj)
        proj["id"] ||= SecureRandom.uuid
        proj["projectName"] = proj["projectName"].to_s
        proj["projectLink"] = proj["projectLink"].to_s
        tech = proj["technologies"]
        proj["technologies"] = tech.is_a?(Array) ? tech.join(", ") : tech.to_s
        proj["description"] = normalise_description(proj["description"])
        proj
      end.compact
    else
      content["projects"] = []
    end

    # Certifications
    certs = content["certifications"]
    if certs.is_a?(Array)
      content["certifications"] = certs.map do |cert|
        next nil unless cert.is_a?(Hash)
        cert = cert.deep_stringify_keys
        next nil if blank_object?(cert)
        cert["id"] ||= SecureRandom.uuid
        cert["certName"] = cert["certName"].to_s
        cert["issuingOrg"] = cert["issuingOrg"].to_s
        cert["issueDate"] = normalise_date(cert["issueDate"])
        cert["credentialUrl"] = cert["credentialUrl"].to_s
        cert
      end.compact
    else
      content["certifications"] = []
    end

    # Achievements
    achievements = content["achievements"]
    if achievements.is_a?(Array)
      content["achievements"] = achievements.map do |ach|
        next nil unless ach.is_a?(Hash)
        ach = ach.deep_stringify_keys
        next nil if blank_object?(ach)
        ach["id"] ||= SecureRandom.uuid
        ach["title"] = ach["title"].to_s
        ach["description"] = ach["description"].to_s
        ach
      end.compact
    else
      content["achievements"] = []
    end

    # Languages
    languages = content["languages"]
    if languages.is_a?(Array)
      content["languages"] = languages.map do |l|
        next nil unless l.is_a?(Hash)
        l = l.deep_stringify_keys
        next nil if blank_object?(l)
        l["id"] ||= SecureRandom.uuid
        l["language"] = l["language"].to_s
        l["proficiency"] = l["proficiency"].to_s
        l
      end.compact
    else
      content["languages"] = []
    end

    # Interests
    interests = content["interests"]
    if interests.is_a?(Array)
      content["interests"] = interests.map do |i|
        if i.is_a?(Hash)
          i = i.deep_stringify_keys
          next nil if blank_object?(i)
          i["name"].to_s
        else
          i.to_s
        end
      end.compact.reject(&:blank?)
    else
      content["interests"] = []
    end

    # Skills
    content["skills"] = content["skills"].is_a?(Hash) ? content["skills"] : {}
    list = content["skills"]["skillList"]
    content["skills"]["skillList"] = list.is_a?(Array) ? list.join(", ") : list.to_s

    content
  end

  def self.find_best_match(orig_item, target_items, matched_targets)
    return nil if orig_item.nil? || target_items.blank?

    # 1. Match by ID (highest priority)
    if orig_item["id"].present?
      match = target_items.find { |t| t.is_a?(Hash) && t["id"].to_s == orig_item["id"].to_s && !matched_targets.include?(t) }
      return match if match
    end

    # 2. Match by company/school/projectName (if present and exact match)
    if orig_item["company"].present?
      match = target_items.find { |t| t.is_a?(Hash) && t["company"].to_s.downcase.strip == orig_item["company"].to_s.downcase.strip && !matched_targets.include?(t) }
      return match if match
    end
    if orig_item["school"].present?
      match = target_items.find { |t| t.is_a?(Hash) && t["school"].to_s.downcase.strip == orig_item["school"].to_s.downcase.strip && !matched_targets.include?(t) }
      return match if match
    end
    if orig_item["projectName"].present?
      match = target_items.find { |t| t.is_a?(Hash) && t["projectName"].to_s.downcase.strip == orig_item["projectName"].to_s.downcase.strip && !matched_targets.include?(t) }
      return match if match
    end

    # 3. Match by role/degree (if present and exact match)
    if orig_item["role"].present?
      match = target_items.find { |t| t.is_a?(Hash) && t["role"].to_s.downcase.strip == orig_item["role"].to_s.downcase.strip && !matched_targets.include?(t) }
      return match if match
    end
    if orig_item["degree"].present?
      match = target_items.find { |t| t.is_a?(Hash) && t["degree"].to_s.downcase.strip == orig_item["degree"].to_s.downcase.strip && !matched_targets.include?(t) }
      return match if match
    end

    # 4. Fuzzy match: check if original company/role is a substring of the target, or vice versa
    if orig_item["company"].present?
      match = target_items.find do |t|
        next unless t.is_a?(Hash) && !matched_targets.include?(t)
        t_comp = t["company"].to_s.downcase.strip
        o_comp = orig_item["company"].to_s.downcase.strip
        t_comp.include?(o_comp) || o_comp.include?(t_comp)
      end
      return match if match
    end
    if orig_item["school"].present?
      match = target_items.find do |t|
        next unless t.is_a?(Hash) && !matched_targets.include?(t)
        t_sch = t["school"].to_s.downcase.strip
        o_sch = orig_item["school"].to_s.downcase.strip
        t_sch.include?(o_sch) || o_sch.include?(t_sch)
      end
      return match if match
    end
    if orig_item["projectName"].present?
      match = target_items.find do |t|
        next unless t.is_a?(Hash) && !matched_targets.include?(t)
        t_proj = t["projectName"].to_s.downcase.strip
        o_proj = orig_item["projectName"].to_s.downcase.strip
        t_proj.include?(o_proj) || o_proj.include?(t_proj)
      end
      return match if match
    end

    nil
  end

  def self.restore_immutable_fields(target, original, action = nil, payload = {})
    original ||= {}
    target ||= {}
    payload ||= {}

    # 1. Restore Personal Info except summary/headline
    if original["personal"].is_a?(Hash)
      target["personal"] ||= {}
      original["personal"].each do |key, val|
        # Headline is immutable! ONLY summary is mutable!
        unless ["summary"].include?(key.to_s)
          target["personal"][key] = val
        end
      end
      # Sanitize personal summary (Issue 3)
      target["personal"]["summary"] = sanitize_text_integrity(target["personal"]["summary"], original.dig("personal", "summary"))
    end

    # 2. Restore Work Experience
    if original["experiences"].is_a?(Array)
      target_exps = target["experiences"] || []
      updated_exps = []
      matched_targets = []
      
      original["experiences"].each_with_index do |orig_exp, idx|
        next unless orig_exp.is_a?(Hash)
        
        # Try to find matching AI exp
        ai_exp = find_best_match(orig_exp, target_exps, matched_targets)
        
        # Fallback to index if not matched and index is valid and not already matched
        if ai_exp.nil? && target_exps[idx].is_a?(Hash) && !matched_targets.include?(target_exps[idx])
          ai_exp = target_exps[idx]
        end

        if ai_exp.is_a?(Hash)
          matched_targets << ai_exp
          merged_exp = ai_exp.dup
          merged_exp["id"] = orig_exp["id"]
          merged_exp["company"] = orig_exp["company"]
          merged_exp["role"] = orig_exp["role"]
          merged_exp["startDate"] = orig_exp["startDate"]
          merged_exp["endDate"] = orig_exp["endDate"]
          
          # Force types and sanitize description (Issue 2, 7)
          merged_exp["description"] = normalise_description(merged_exp["description"])
          merged_exp["description"] = sanitize_text_integrity(merged_exp["description"], orig_exp["description"])
          
          if merged_exp["bulletPoints"].present?
            orig_bullets = Array(orig_exp["bulletPoints"]).join(" ")
            merged_exp["bulletPoints"] = Array(merged_exp["bulletPoints"]).map do |bullet|
              sanitize_text_integrity(bullet.to_s, orig_bullets)
            end.reject(&:blank?)
          end
          updated_exps << merged_exp
        else
          updated_exps << orig_exp.dup
        end
      end
      target["experiences"] = updated_exps
    end

    # 3. Restore Educations
    if original["educations"].is_a?(Array)
      target_edus = target["educations"] || []
      updated_edus = []
      matched_targets = []

      original["educations"].each_with_index do |orig_edu, idx|
        next unless orig_edu.is_a?(Hash)
        
        # Try to find matching AI edu
        ai_edu = find_best_match(orig_edu, target_edus, matched_targets)
        
        # Fallback to index if not matched and index is valid and not already matched
        if ai_edu.nil? && target_edus[idx].is_a?(Hash) && !matched_targets.include?(target_edus[idx])
          ai_edu = target_edus[idx]
        end

        if ai_edu.is_a?(Hash)
          matched_targets << ai_edu
          merged_edu = ai_edu.dup
          merged_edu["id"] = orig_edu["id"]
          merged_edu["school"] = orig_edu["school"]
          merged_edu["degree"] = orig_edu["degree"]
          merged_edu["startDate"] = orig_edu["startDate"]
          merged_edu["endDate"] = orig_edu["endDate"]
          merged_edu["cgpa"] = orig_edu["cgpa"]
          updated_edus << merged_edu
        else
          updated_edus << orig_edu.dup
        end
      end
      target["educations"] = updated_edus
    end

    # 4. Restore Certifications
    if original["certifications"].is_a?(Array)
      target_certs = target["certifications"] || []
      updated_certs = []
      matched_targets = []

      original["certifications"].each_with_index do |orig_cert, idx|
        next unless orig_cert.is_a?(Hash)

        # Try to find matching AI cert
        ai_cert = find_best_match(orig_cert, target_certs, matched_targets)
        
        # Fallback to index if not matched and index is valid and not already matched
        if ai_cert.nil? && target_certs[idx].is_a?(Hash) && !matched_targets.include?(target_certs[idx])
          ai_cert = target_certs[idx]
        end

        if ai_cert.is_a?(Hash)
          matched_targets << ai_cert
          merged_cert = ai_cert.dup
          merged_cert["id"] = orig_cert["id"]
          merged_cert["certName"] = orig_cert["certName"]
          merged_cert["issuingOrg"] = orig_cert["issuingOrg"]
          merged_cert["issueDate"] = orig_cert["issueDate"]
          merged_cert["credentialUrl"] = orig_cert["credentialUrl"]
          updated_certs << merged_cert
        else
          updated_certs << orig_cert.dup
        end
      end
      target["certifications"] = updated_certs
    end

    # 5. Restore Project links & title (Issue 1)
    if original["projects"].is_a?(Array)
      target_projs = target["projects"] || []
      updated_projs = []
      matched_targets = []

      original["projects"].each_with_index do |orig_proj, idx|
        next unless orig_proj.is_a?(Hash)

        # Try to find matching AI proj
        ai_proj = find_best_match(orig_proj, target_projs, matched_targets)
        
        # Fallback to index if not matched and index is valid and not already matched
        if ai_proj.nil? && target_projs[idx].is_a?(Hash) && !matched_targets.include?(target_projs[idx])
          ai_proj = target_projs[idx]
        end

        if ai_proj.is_a?(Hash)
          matched_targets << ai_proj
          merged_proj = ai_proj.dup
          merged_proj["id"] = orig_proj["id"]
          
          # Allow project title to change ONLY if we are explicitly running project title generation/improvement for this specific project
          is_title_gen = (action == "optimize_project" && 
                          orig_proj["id"].present? && 
                          orig_proj["id"].to_s == payload[:project_id].to_s && 
                          ["generate_title", "improve_title"].include?(payload[:project_action]))
          
          unless is_title_gen
            merged_proj["projectName"] = orig_proj["projectName"]
          end
          merged_proj["projectLink"] = orig_proj["projectLink"]
          
          # Force types and sanitize description (Issue 7)
          merged_proj["description"] = normalise_description(merged_proj["description"])
          merged_proj["description"] = sanitize_text_integrity(merged_proj["description"], orig_proj["description"])
          
          tech = merged_proj["technologies"]
          merged_proj["technologies"] = tech.is_a?(Array) ? tech.join(", ") : tech.to_s
          
          updated_projs << merged_proj
        else
          updated_projs << orig_proj.dup
        end
      end
      target["projects"] = updated_projs
    end

    target
  end

  def self.normalize_bullet_for_comparison(bullet)
    bullet.to_s.gsub(/\A\s*[-*•●▪◦■◆★+]\s*/, "").strip.downcase
  end

  def self.get_first_bullet(resume)
    exp = resume.content["experiences"]&.first
    return "" unless exp
    desc = exp["description"].to_s
    bullets = desc.split(/\r?\n/).map(&:strip).reject(&:blank?)
    if bullets.size <= 1
      bullet_regex = /\s*[•●▪◦■◆★]\s*|\s+[-\*]\s+/
      if desc.scan(bullet_regex).size > 0
        bullets = desc.split(bullet_regex).map(&:strip).reject(&:blank?)
      end
    end
    bullets.first || ""
  end

  def self.validate_bullet_response(text)
    text = text.to_s.strip

    # 3. Maximum Length
    if text.length > 600
      raise OptimizationError, "AI generation failed. Response is too long (exceeds 600 characters)."
    end

    # 5. No Markdown headings, rules, code blocks, tables
    # Reject: #, ##, ***, ---, ```markdown, tables, headings
    if text =~ /(?:\A|\n)\s*[\#]{1,6}\s+/ || text.include?("#")
      raise OptimizationError, "AI generation failed. Response contains markdown headings."
    end

    if text.include?("***") || text.include?("---")
      raise OptimizationError, "AI generation failed. Response contains markdown separators."
    end

    if text.include?("```")
      raise OptimizationError, "AI generation failed. Response contains code fences."
    end

    if text.include?("|") && text.include?("-")
      raise OptimizationError, "AI generation failed. Response contains tables."
    end

    # 2. Response Validation: Reject if response contains
    # # headings, ## headings, **Summary**, **Experience**, **Education**, **Projects**, **Skills**, "Resume", "Professional Summary", "=========="
    if text.include?("==========")
      raise OptimizationError, "AI generation failed. Response contains separators."
    end

    # Reject entire JSON
    if (text.start_with?("{") && text.end_with?("}")) || (text.start_with?("[") && text.end_with?("]"))
      raise OptimizationError, "AI generation failed. Response is a JSON object/array instead of a plain bullet."
    end

    # Reject Markdown lists
    if text =~ /(?:\A|\n)\s*(?:[-*+]\s|\d+\.\s)/
      raise OptimizationError, "AI generation failed. Response contains markdown lists."
    end

    # 4. No Cross Section Content headings (Check if any line consists solely of a section name)
    cross_section_words = [
      "summary", "education", "projects", "experience", "skills",
      "professional summary", "certifications", "languages", "achievements", "interests", "resume"
    ]
    text.to_s.split(/\r?\n/).each do |line|
      clean_line = line.gsub(/\A[\#\*\_:\-\s]+|[\#\*\_:\-\s]+\z/, "").strip.downcase
      if cross_section_words.include?(clean_line)
        raise OptimizationError, "AI generation failed. Response contains cross-section content: '#{clean_line}'."
      end
    end
  end
end
