module ScoreEngine
  class ContentCompletenessChecker
    def initialize(resume)
      @resume = resume
      @content = ResumeContentNormalizer.normalize(resume.content)
    end

    def evaluate
      sections = %w[personal summary experiences educations skills projects certifications]
      
      results = {}
      total_score = 0

      sections.each do |sec|
        status, points, reasoning, meta = evaluate_section(sec)
        results[sec] = { status: status, points: points, reasoning: reasoning }
        results[sec].merge!(meta) if meta.is_a?(Hash)
        total_score += points
      end

      # Normalize score to 100
      max_possible = 120 # Adjust based on weights
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
        if val.blank? || !val.is_a?(String)
          ['missing', 0, 'Professional Summary is missing.']
        else
          quality_score, quality_status, quality_reasoning = score_summary_quality(val)
          [quality_status, quality_score, quality_reasoning]
        end
      when 'experiences'
        # A valid experience entry must have at least one of these fields present
        has_content = val.present? && val.is_a?(Array) && val.any? { |e| e['company'].present? || e['role'].present? || e['description'].present? }
        if has_content
          quality_score, quality_status, quality_reasoning = score_experience_quality(val)
          [quality_status, quality_score, quality_reasoning]
        else
          ['missing', 0, 'Experience section is missing.']
        end
      when 'educations'
        # CareerAI stores institution name under 'school' (the frontend field name).
        # Also accept 'institution', 'university', 'college' for forward-compatibility.
        institution_aliases = %w[school institution university college school_name]
        has_content = val.present? && val.is_a?(Array) && val.any? { |e|
          institution_aliases.any? { |k| e[k].present? } || e['degree'].present?
        }
        if has_content
          quality_score, quality_status, quality_reasoning = score_education_quality(val)
          [quality_status, quality_score, quality_reasoning]
        else
          ['missing', 0, 'Education section is missing.']
        end
      when 'skills'
        if val.present? && val.is_a?(Array) && val.any?
          quality_score, quality_status, quality_reasoning, category_meta = score_skills_quality(val)
          meta = { count: val.size, cleaned_skills: val }.merge(category_meta || {})
          [quality_status, quality_score, quality_reasoning, meta]
        else
          ['missing', 0, 'Skills section is missing.', { count: 0, cleaned_skills: [], present_categories: [], missing_categories: [], category_suggestions: [] }]
        end
      when 'projects'
        # A valid project entry must have at least projectName or description present
        has_content = val.present? && val.is_a?(Array) && val.any? { |p| p['projectName'].present? || p['description'].present? }
        if has_content
          quality_score, quality_status, quality_reasoning, meta = score_projects_quality(val)
          [quality_status, quality_score, quality_reasoning, meta]
        else
          ['missing', 0, 'Projects section is missing.', { problems: ['Projects section is missing entirely.'], suggestions: ['Add your first project.', 'Aim for at least two strong projects.'] }]
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

    # ─────────────────────────────────────────────────────────────
    # EDUCATION QUALITY SCORER
    # Evaluates the quality of the Education array across 3 core dimensions and 2 quality dimensions.
    # Returns [points (0-20), status, reasoning_string].
    # Max points breakdown:
    #   School          : 4 pts
    #   Degree          : 4 pts
    #   Dates           : 4 pts
    #   Field of Study  : 4 pts (explicit major key or extracted from degree field)
    #   CGPA / Grade    : 4 pts
    # ─────────────────────────────────────────────────────────────
    def score_education_quality(educations)
      points = 0
      problems = []

      # ── 1. Core Fields (0-12 pts) ───────────────────────────────
      # Institution / School — check all aliases the frontend may use
      institution_keys = %w[school institution university college school_name]
      missing_school = educations.count { |e| institution_keys.none? { |k| e[k].present? } }
      missing_degree  = educations.count { |e| e['degree'].blank? }
      missing_dates   = educations.count { |e| e['startDate'].blank? && e['endDate'].blank? && e['year'].blank? && e['graduationYear'].blank? }

      if missing_school == 0
        points += 4
      else
        problems << "Missing institution name in some entries"
      end

      if missing_degree == 0
        points += 4
      else
        problems << "Missing degree/qualification in some entries"
      end

      if missing_dates == 0
        points += 4
      else
        problems << "Missing graduation year or dates in some entries"
      end

      # ── 2. Field of Study (0-4 pts) ───────────────────────────
      field_keys = %w[field fieldOfStudy major subject specialization]
      has_field = educations.any? { |e| field_keys.any? { |k| e[k].present? } }

      # If not explicitly in a field key, check if it's embedded in the degree string
      unless has_field
        major_keywords = [
          "computer science", "cse", "information technology", "software engineering",
          "mechanical", "electrical", "civil", "electronics", "chemical", "aerospace",
          "biotechnology", "physics", "chemistry", "mathematics", "math", "biology",
          "economics", "finance", "accounting", "business", "marketing", "management",
          "english", "history", "psychology", "sociology", "political science", "philosophy",
          "art", "design", "human resources", "nursing", "medicine", "law", "statistics",
          "data science", "artificial intelligence", "machine learning", "ece", "it",
          "ee", "me", "mba", "mca", "bca"
        ]
        has_field = educations.any? do |e|
          deg = e['degree'].to_s.downcase
          major_keywords.any? { |kw| deg.include?(kw) }
        end
      end

      if has_field
        points += 4
      else
        problems << "Missing field of study or major"
      end

      # ── 3. CGPA / Grade (0-4 pts) ─────────────────────────
      grade_keys = %w[gpa cgpa grade percentage score]
      has_grade = educations.any? { |e| grade_keys.any? { |k| e[k].present? } }
      if has_grade
        points += 4
      else
        problems << "Consider adding your CGPA, GPA, or percentage if it is strong"
      end

      # Log the scoring breakdown to Rails Logger for auditing
      Rails.logger.info "Education Scorer Breakdown:"
      Rails.logger.info "School: #{missing_school == 0 ? '+4' : '+0'}"
      Rails.logger.info "Degree: #{missing_degree == 0 ? '+4' : '+0'}"
      Rails.logger.info "Dates: #{missing_dates == 0 ? '+4' : '+0'}"
      Rails.logger.info "Field: #{has_field ? '+4' : '+0'}"
      Rails.logger.info "CGPA: #{has_grade ? '+4' : '+0'}"
      Rails.logger.info "TOTAL: #{points} / 20"

      # ── Status thresholds (max = 20 pts) ──────────────────────
      # 'complete'  ≥ 16  → Excellent
      # 'weak'      ≥ 9   → Needs Work
      # 'poor'      < 9   → Critical
      status = if points >= 16
        'complete'
      elsif points >= 9
        'weak'
      else
        'poor'
      end

      reasoning = if problems.any?
        "Issues: #{problems.join('; ')}."
      else
        "Excellent education section."
      end

      [points, status, reasoning]
    end

    # ─────────────────────────────────────────────────────────────
    # EXPERIENCE QUALITY SCORER
    # Evaluates the quality of the Work Experience array across 6 dimensions.
    # Returns [points (0-30), status, reasoning_string].
    # ─────────────────────────────────────────────────────────────
    def score_experience_quality(experiences)
      points = 0
      problems = []
      signals = []

      # ── 1. Core fields (0-9 pts) ────────────────────────────────
      missing_company = experiences.count { |e| e['company'].blank? }
      missing_role = experiences.count { |e| e['role'].blank? }
      missing_dates = experiences.count { |e| e['startDate'].blank? && e['endDate'].blank? }
      
      if missing_company == 0
        points += 3
      else
        problems << "Missing company name in some entries"
      end

      if missing_role == 0
        points += 3
      else
        problems << "Missing role/title in some entries"
      end

      if missing_dates == 0
        points += 3
      else
        problems << "Missing dates in some entries"
      end

      # Combine descriptions for deeper analysis
      all_descriptions = experiences.map { |e| e['description'].to_s }.join("\n")
      words = all_descriptions.split(/\s+/).reject(&:empty?)
      desc_lower = all_descriptions.downcase

      # ── 2. Meaningful Description (0-4 pts) ────────────────────
      if words.size >= 80
        points += 4
      elsif words.size >= 30
        points += 2
        problems << "Descriptions are a bit short; expand with more details"
      else
        problems << "Descriptions are too brief; add comprehensive bullet points"
      end

      # ── 3. Responsibilities / Bullet points (0-4 pts) ──────────
      # Check if there are multiple lines/sentences representing responsibilities
      sentences = all_descriptions.split(/(?<=[.!?])\s+|[\n•\-]+/).reject(&:empty?)
      if sentences.size >= 4
        points += 4
      elsif sentences.size >= 2
        points += 2
        problems << "Add more distinct responsibilities or bullet points"
      else
        problems << "List your responsibilities clearly using bullet points"
      end

      # ── 4. Technologies / Skills (0-3 pts) ────────────────────
      tech_keywords = %w[java python ruby javascript react vue angular node rails spring aws azure gcp sql postgres mysql docker kubernetes git agile]
      tech_hits = tech_keywords.count { |kw| desc_lower.include?(kw) }
      if tech_hits >= 3
        points += 3
      elsif tech_hits >= 1
        points += 1
        problems << "Mention more specific tools and technologies you used"
      else
        problems << "No specific tools, software, or technologies mentioned"
      end

      # ── 5. Action Verbs (0-2 pts) ─────────────────────────────
      action_verbs = %w[developed built designed managed led created optimized reduced increased implemented launched resolved drove spearheaded architected scaled]
      action_hits = action_verbs.count { |v| desc_lower.include?(v) }
      if action_hits >= 3
        points += 2
      elsif action_hits >= 1
        points += 1
        problems << "Start bullet points with strong action verbs"
      else
        problems << "Lacking action verbs; avoid passive phrases like 'worked on'"
      end

      # ── 6. Metrics / Quantified Impact (0-3 pts) ──────────────
      metrics_hits = all_descriptions.scan(/\d+%|\$\d+|\b\d{2,}\b/).size
      if metrics_hits >= 2
        points += 3
        signals << "Excellent use of metrics"
      elsif metrics_hits == 1
        points += 1
        problems << "Add more quantifiable metrics (%, $, numbers) to demonstrate scale"
      else
        problems << "No measurable impact found; quantify your achievements"
      end

      # ── 7. Ownership / Leadership (0-2 pts) ───────────────────
      ownership_keywords = %w[led lead managed architected designed mentored owned directed oversaw drove]
      own_hits = ownership_keywords.count { |kw| desc_lower.include?(kw) }
      if own_hits >= 1
        points += 2
      else
        problems << "Missing signs of ownership (e.g. Led, Architected, Managed)"
      end

      # ── 8. Business Impact (0-3 pts) ──────────────────────────
      impact_keywords = %w[revenue cost sales retention latency load efficiency growth user customer scale performance]
      impact_hits = impact_keywords.count { |kw| desc_lower.include?(kw) }
      if impact_hits >= 2
        points += 3
      elsif impact_hits == 1
        points += 1
        problems << "Connect your technical work to business impact (e.g. revenue, efficiency, performance)"
      else
        problems << "No explicit business impact mentioned"
      end

      # ── Status thresholds (max = 30 pts) ──────────────────────
      # 'complete'  ≥ 24  → Excellent
      # 'weak'      ≥ 15  → Needs Work
      # 'poor'      < 15  → Critical
      status = if points >= 24
        'complete'
      elsif points >= 15
        'weak'
      else
        'poor'
      end

      reasoning = if problems.any?
        "Issues: #{problems.join('; ')}."
      else
        "Excellent experience section."
      end

      [points, status, reasoning]
    end

    # ─────────────────────────────────────────────────────────────
    # SKILLS QUALITY SCORER
    # Evaluates the quality of the Skills array.
    # Returns [points (0-15), status, reasoning_string].
    # ─────────────────────────────────────────────────────────────
    def score_skills_quality(skills)
      problems = []
      suggestions = []
      present_categories = []
      missing_categories = []

      normalized = skills.map(&:downcase)

      # ── Category dictionaries ──────────────────────────────────
      categories = {
        'Programming Languages' => %w[python java ruby c# c++ go rust kotlin swift scala php typescript javascript],
        'Frontend' => %w[react vue angular nextjs svelte html css tailwind sass bootstrap jquery],
        'Backend' => %w[node express rails django flask spring fastapi graphql rest restful],
        'Databases' => %w[sql mysql postgres postgresql mongodb redis elasticsearch firebase sqlite oracle],
        'Cloud' => %w[aws azure gcp google heroku vercel netlify ec2 s3 lambda cloudfront],
        'DevOps' => %w[docker kubernetes jenkins ci/cd terraform ansible linux devops nginx],
        'Testing' => %w[jest cypress rspec mocha jasmine junit pytest selenium playwright],
        'Version Control' => %w[git github gitlab bitbucket],
        'Mobile' => %w[react-native flutter android ios swift kotlin],
        'Data / ML' => %w[pandas numpy tensorflow pytorch scikit-learn jupyter data machine-learning ml ai],
        'Soft Skills' => %w[communication leadership teamwork collaboration problem-solving management agile scrum]
      }

      # ── Check which categories are covered ────────────────────
      categories.each do |category, keywords|
        hit = keywords.any? { |kw| normalized.any? { |s| s.include?(kw) } }
        if hit
          present_categories << category
        else
          missing_categories << category
        end
      end

      # ── Count skills ───────────────────────────────────────────
      count = skills.size

      # ── Targeted issue generation based on missing categories ──
      if missing_categories.include?('Cloud')
        problems << "No cloud platforms detected"
        suggestions << "Add cloud platforms such as AWS, Azure, or GCP"
      end
      if missing_categories.include?('DevOps')
        problems << "No DevOps or containerization tools detected"
        suggestions << "Include tools like Docker, Kubernetes, or CI/CD"
      end
      if missing_categories.include?('Testing')
        problems << "No testing frameworks detected"
        suggestions << "Add testing frameworks such as Jest, Cypress, or PyTest"
      end
      if missing_categories.include?('Soft Skills')
        problems << "No soft skills detected"
        suggestions << "Add communication, leadership, or teamwork skills"
      end
      if missing_categories.include?('Databases')
        problems << "No database skills detected"
        suggestions << "Include databases like PostgreSQL, MySQL, or MongoDB"
      end
      if count < 10
        problems << "Only #{count} skill#{count == 1 ? '' : 's'} listed; aim for 10–15+"
        suggestions << "Organize skills into categories (Frontend, Backend, Cloud, etc.)"
      end

      # Calculate base points based on count of skills
      points = if count >= 15
        15
      elsif count >= 10
        12
      elsif count >= 5
        8
      else
        4
      end

      # Deduct 3 points for each critical missing category (Cloud, DevOps, Testing, Soft Skills, Databases)
      # up to a maximum deduction that keeps points >= 2
      critical_missing_count = 0
      critical_missing_count += 1 if missing_categories.include?('Cloud')
      critical_missing_count += 1 if missing_categories.include?('DevOps')
      critical_missing_count += 1 if missing_categories.include?('Testing')
      critical_missing_count += 1 if missing_categories.include?('Soft Skills')
      critical_missing_count += 1 if missing_categories.include?('Databases')

      points -= critical_missing_count * 3
      points = [points, 2].max

      status = if points >= 12
        'complete'
      elsif points >= 8
        'weak'
      else
        'poor'
      end

      # ── Build reasoning for issues list ───────────────────────
      reasoning = if problems.any?
        "Issues: #{problems.join('; ')}."
      else
        "Excellent skills coverage."
      end

      # Attach suggestions as metadata for the frontend
      [points, status, reasoning, {
        present_categories: present_categories,
        missing_categories: missing_categories,
        category_suggestions: suggestions
      }]
    end

    # ─────────────────────────────────────────────────────────────
    # SUMMARY QUALITY SCORER
    # Evaluates actual quality of a Professional Summary string.
    # Returns [points (0-10), status, reasoning_string].
    # Points map 1:1 to the completeness section weight (10 max).
    # ─────────────────────────────────────────────────────────────
    def score_summary_quality(text)
      t      = text.to_s.strip
      words  = t.split(/\s+/).reject(&:empty?)
      word_count  = words.size
      sentences   = t.split(/[.!?]+/).map(&:strip).reject(&:empty?)
      sentence_count = sentences.size

      points   = 0
      problems = []
      signals  = []

      # ── 1. Word count (0-2 pts) ────────────────────────────────
      # Reduced from 3 to free up weight for the achievement dimension.
      if word_count >= 50
        points += 2
        signals << "Good length (#{word_count} words)"
      elsif word_count >= 25
        points += 1
        problems << "Summary is a bit short (#{word_count} words); aim for 50-80 words"
      else
        problems << "Summary is too short (#{word_count} #{'word'.pluralize(word_count)}); aim for 50-80 words"
      end

      # ── 2. Sentence count (0-1 pt) ────────────────────────────
      if sentence_count >= 2
        points += 1
        signals << "#{sentence_count} sentences"
      else
        problems << "Only #{sentence_count} sentence; aim for 2-4 sentences"
      end

      # ── 3. Professional role / title signal (0-2 pts) ─────────
      role_keywords = %w[
        developer engineer manager analyst designer architect
        lead senior principal director specialist consultant
        scientist researcher programmer administrator officer
      ]
      has_role = role_keywords.any? { |kw| t.downcase.include?(kw) }
      if has_role
        points += 2
        signals << "Mentions professional role"
      else
        problems << "Missing professional title or role (e.g. 'Software Developer', 'Product Manager')"
      end

      # ── 4. Skills / technologies mention (0-2 pts) ────────────
      # Require ≥4 hits for full credit (raised from ≥3).
      skill_keywords = %w[
        java python ruby javascript react vue angular node rails
        spring django flask docker kubernetes aws azure gcp
        sql postgres mysql mongodb redis git agile scrum
        leadership communication management strategy
      ]
      skill_hits = skill_keywords.count { |kw| t.downcase.include?(kw) }
      if skill_hits >= 4
        points += 2
        signals << "Mentions multiple skills/technologies"
      elsif skill_hits >= 1
        points += 1
        signals << "Mentions some skills"
        problems << "List more specific technologies to strengthen the summary"
      else
        problems << "No skills or technologies mentioned"
      end

      # ── 5. Achievement / impact / value proposition (0-3 pts) ─
      # Raised weight to 3 pts. Removed passive nouns (experience, results,
      # track record, impact, success, growth, performance, revenue, cost)
      # that appear in generic summaries without representing real achievement.
      # Only strong action verbs and outcome-oriented root forms remain.
      achievement_keywords = %w[
        led lead managed directed
        built build delivered deliver
        increased increas improved improv
        reduced reduc launched launch
        designed design implemented implement
        architected architect optimized optim
        achieved achiev scaled scale
        drove drive generated generat
        spearheaded pioneer transformed
        streamlined established created innovated
      ]
      ach_hits = achievement_keywords.count { |kw| t.downcase.include?(kw) }
      if ach_hits >= 3
        points += 3
        signals << "Strong achievement and impact language"
      elsif ach_hits >= 1
        points += 1
        signals << "Some action language present"
        problems << "Add measurable achievements or outcomes (e.g. 'Led', 'Delivered', 'Increased X by Y%')"
      else
        problems << "No achievement language — mention what you built, led, or delivered"
      end

      # ── Status thresholds (max = 10 pts) ──────────────────────
      # 'complete'  ≥ 9  → Excellent  (previously 8 — too easy)
      # 'weak'      ≥ 6  → Needs Work
      # 'poor'      < 6  → Critical   (exists but very low quality)
      #
      # A generic summary with role + skills + words but no real
      # achievements should land in 'weak' (60-70%), not 'complete'.
      status = if points >= 9
        'complete'  # → Excellent badge
      elsif points >= 6
        'weak'      # → Needs Work badge
      else
        'poor'      # → Critical badge (present but very poor quality)
      end

      reasoning = if problems.any?
        "Issues: #{problems.join('; ')}."
      else
        "#{signals.join('; ')}."
      end

      [points, status, reasoning]
    end

    # ─────────────────────────────────────────────────────────────
    # PROJECTS QUALITY SCORER
    # Evaluates the quality of the Projects array across 8 dimensions.
    # Returns [points (0-30), status, reasoning_string, metadata].
    # Max points breakdown:
    #   Project Count             : 12 pts (1 = 6 pts, 2 = 10 pts, 3+ = 12 pts)
    #   Project Title             : 3 pts
    #   Description Length/Quality: 5 pts
    #   Technologies              : 4 pts
    #   Responsibilities/Features : 3 pts
    #   Action Verbs              : 2 pts
    #   Impact / Metrics          : 3 pts
    #   Links                     : 2 pts
    # ─────────────────────────────────────────────────────────────
    def score_projects_quality(projects)
      points = 0
      hard_problems = []
      opt_opportunities = []
      suggestions = []

      # 1. Project Count (0-12 pts)
      count = projects.size
      count_pts = if count == 0
        0
      elsif count == 1
        opt_opportunities << "Only one project listed"
        suggestions << "Aim for at least two strong projects"
        6
      elsif count == 2
        10
      else
        12
      end
      points += count_pts

      # 2. Project Title (0-3 pts)
      has_titles = projects.all? { |p| p['projectName'].present? && p['projectName'].strip.length > 2 }
      if has_titles
        points += 3
      else
        hard_problems << "Weak project titles"
        suggestions << "Ensure all projects have a clear, descriptive title"
      end

      # 3. Description Length/Quality (0-5 pts)
      avg_desc_len = projects.any? ? (projects.map { |p| p['description'].to_s.strip.length }.sum / projects.size.to_f) : 0
      if avg_desc_len >= 100
        points += 5
      elsif avg_desc_len > 0
        points += 2
        hard_problems << "Descriptions are too short"
        suggestions << "Describe your project implementation details and architectural decisions"
      else
        hard_problems << "Project lacks implementation details"
        suggestions << "Describe your project implementation and goals"
      end

      # 4. Technologies (0-4 pts)
      tech_keywords = %w[react vue angular node express ruby rails python java c# go mongodb postgresql postgres redis docker aws azure gcp tailwind next.js graphql]
      detected_techs_count = projects.map do |p|
        techs_str = p['technologies'].to_s.strip
        if techs_str.present?
          techs_str.split(/[\s,;\/|]+/).reject(&:empty?).size
        else
          combined = p['description'].to_s.downcase
          tech_keywords.count { |kw| combined =~ /\b#{Regexp.escape(kw)}\b/ }
        end
      end.max || 0

      if detected_techs_count >= 3
        points += 4
      elsif detected_techs_count >= 1
        points += 2
        opt_opportunities << "Consider listing additional technologies, frameworks, or tools"
        suggestions << "Expand your technology stack if additional tools or frameworks were used"
        suggestions << "Mention backend, deployment, cloud, or database technologies where applicable"
      else
        hard_problems << "No technologies listed"
        suggestions << "List the key programming languages, frameworks, and tools used"
      end

      # 5. Responsibilities / Features (0-3 pts)
      impl_keywords = [
        "built", "developed", "designed", "created", "implemented", "integrated", 
        "responsive", "authentication", "dashboard", "api", "crud", "payment", 
        "deployment", "admin panel", "chat", "resume builder", "ai", "analytics"
      ]

      has_impl_detail = projects.any? do |p|
        desc = p['description'].to_s.downcase
        impl_keywords.any? { |kw| desc =~ /\b#{Regexp.escape(kw)}\b/ } || desc.include?('•') || desc.include?('-') || desc.split(/[.!?]/).size >= 3
      end

      is_genuinely_minimal = projects.any? { |p| p['description'].to_s.strip.length < 40 }

      if is_genuinely_minimal
        hard_problems << "Expand the project description"
        hard_problems << "Project lacks implementation details"
        suggestions << "Provide more context on what the project does and its core objectives"
      elsif has_impl_detail
        points += 3
        # Encourage adding advanced info depending on description density
        if avg_desc_len < 100
          suggestions << "Describe architecture, technical challenges, or implementation details for a stronger impact"
        else
          suggestions << "Highlight the project architecture, scalability, or technical challenges you solved"
          suggestions << "Mention any measurable outcomes or business value generated"
        end
      else
        hard_problems << "Project lacks implementation details"
        suggestions << "Explain what you built, your specific role, and core features"
      end

      # 6. Action Verbs (0-2 pts)
      action_verbs = %w[built developed designed created implemented optimized architected integrated]
      has_action_verbs = projects.any? do |p|
        desc = p['description'].to_s.downcase
        action_verbs.any? { |v| desc =~ /\b#{Regexp.escape(v)}\b/ }
      end
      if has_action_verbs
        points += 2
      else
        opt_opportunities << "Descriptions lack strong action verbs"
        suggestions << "Start description points with action verbs like Built, Developed, or Architected"
      end

      # 7. Impact / Metrics / Technical Achievements (0-3 pts)
      quantitative_keywords = %w[users downloads performance latency speed reduced improved %]
      has_quantitative_impact = projects.any? do |p|
        desc = p['description'].to_s.downcase
        quantitative_keywords.any? { |k| k == '%' ? desc.include?('%') : desc =~ /\b#{Regexp.escape(k)}\b/ } || desc =~ /\b\d+(%|x|\s*percent|\s*users|\s*downloads|\s*ms|\s*kb|\s*mb|\s*gb)\b/i
      end

      tech_impact_keywords = [
        "jwt", "authentication", "rest api", "responsive", "ai", "docker", "redis",
        "background jobs", "payment", "role-based", "chat", "websockets", "microservices",
        "kubernetes", "ci/cd", "caching", "queue"
      ]
      has_tech_impact = projects.any? do |p|
        combined = "#{p['technologies']} #{p['description']}".downcase
        tech_impact_keywords.any? { |k| combined =~ /\b#{Regexp.escape(k)}\b/ }
      end

      if has_quantitative_impact || has_tech_impact
        points += 3
      else
        opt_opportunities << "Add measurable results or highlight technical achievements"
        suggestions << "Quantify your achievements or highlight strong technical complexity (e.g., JWT auth, Redis, CI/CD)"
      end

      # 8. Links (0-2 pts)
      link_fields = %w[projectLink projectUrl url liveUrl github repository repo demo website portfolio]
      placeholder_patterns = [
        /\A(https?:\/\/)?(www\.)?github\.com\/\.{3}\z/i,
        /\A(https?:\/\/)?(www\.)?github\.com\/yourusername\z/i,
        /\A(https?:\/\/)?(www\.)?github\.com\/your-username\z/i,
        /\A(https?:\/\/)?(www\.)?github\.com\/username\z/i,
        /\A(https?:\/\/)?(www\.)?github\.com\/user\z/i,
        /\A(https?:\/\/)?(www\.)?github\.com\/example\z/i,
        /\A(https?:\/\/)?(www\.)?example\.com\/?\z/i,
        /\A(https?:\/\/)?(www\.)?your-portfolio\.com\/?\z/i,
        /\A(https?:\/\/)?(www\.)?localhost\b/i
      ]

      missing_link_projects = []
      has_any_link = false

      projects.each do |p|
        has_link = link_fields.any? do |field|
          val = p[field].to_s.strip
          is_url = val =~ /\A(https?:\/\/)?(www\.)?[a-zA-Z0-9\-]+(\.[a-zA-Z0-9\-]+)+(\/[^\s]*)?\z/i
          is_not_placeholder = is_url && !placeholder_patterns.any? { |pattern| val =~ pattern } && val != "#"
          is_not_placeholder
        end

        if has_link
          has_any_link = true
        else
          name = p['projectName'].to_s.strip
          name = "Untitled Project" if name.blank?
          missing_link_projects << name
        end
      end

      if projects.any?
        if missing_link_projects.empty?
          points += 2
        elsif has_any_link
          points += 1
        end

        if !has_any_link
          hard_problems << "No project links"
          suggestions << "Add links to GitHub repositories, live demos, or portfolios."
        elsif missing_link_projects.any?
          missing_link_projects.each do |name|
            hard_problems << "Project '#{name}' is missing a project link"
            suggestions << "Add a repository or demo link for project '#{name}'."
          end
        end
      end

      # Cap total points at 30
      points = [points, 30].min

      # A section is not complete if any project is missing description or technologies
      any_project_incomplete = projects.any? do |p|
        p['description'].to_s.strip.length < 40 || p['technologies'].to_s.strip.blank?
      end

      # Status thresholds
      status = if points >= 24 && !any_project_incomplete
        'complete'
      elsif points >= 15
        'weak'
      else
        'poor'
      end

      # If Excellent, move optimization opportunities to suggestions and keep problems empty of optimization opportunities
      problems = if status == 'complete'
        hard_problems
      else
        hard_problems + opt_opportunities
      end

      # Build suggestions dynamically based ONLY on actual deficiencies
      final_suggestions = []

      # 1. Project Count
      if count_pts < 12
        final_suggestions << "Consider adding another project to strengthen your portfolio."
      end

      # 2. Project Title
      if !has_titles
        final_suggestions << "Ensure all projects have a clear, descriptive title."
      end

      # 3. Description Length
      if avg_desc_len < 100
        if is_genuinely_minimal
          final_suggestions << "Provide more context on what the project does and its core objectives."
        else
          final_suggestions << "Describe your project implementation details and architectural decisions."
        end
      end

      # 4. Technologies
      if detected_techs_count < 3
        if detected_techs_count == 0
          final_suggestions << "List the key programming languages, frameworks, and tools used."
        else
          final_suggestions << "Expand your technology stack if additional tools or frameworks were used."
          final_suggestions << "Mention backend, deployment, cloud, or database technologies where applicable."
        end
      end

      # 5. Technical Implementation Detail
      if is_genuinely_minimal || !has_impl_detail
        final_suggestions << "Explain what you built, your specific role, and core features."
      end

      # 6. Action Verbs
      if !has_action_verbs
        final_suggestions << "Start description points with action verbs like Built, Developed, or Architected."
      end

      # 7. Impact / Metrics
      if !has_quantitative_impact && !has_tech_impact
        final_suggestions << "Quantify your achievements or highlight strong technical complexity (e.g., JWT auth, Redis, CI/CD)."
      end

      # 8. Links
      if !has_any_link
        final_suggestions << "Add links to GitHub repositories, live demos, or portfolios."
      end

      # Excellent status behavior - show optional growth suggestions if no missing details exist
      if status == 'complete'
        if final_suggestions.empty?
          final_suggestions << "Consider adding another project to strengthen your portfolio."
          final_suggestions << "Keep projects updated."
          final_suggestions << "Add recent work as you build more applications."
        end
      end

      # Log the scoring breakdown to Rails Logger for auditing
      Rails.logger.info "Projects Scorer Breakdown:"
      Rails.logger.info "Count: #{count_pts}"
      Rails.logger.info "Title: #{has_titles ? '+3' : '+0'}"
      Rails.logger.info "Description: #{avg_desc_len >= 100 ? '+5' : (avg_desc_len > 0 ? '+2' : '+0')}"
      Rails.logger.info "Techs: #{detected_techs_count >= 3 ? '+4' : (detected_techs_count >= 1 ? '+2' : '+0')}"
      Rails.logger.info "Features: #{has_impl_detail && !is_genuinely_minimal ? '+3' : '+0'}"
      Rails.logger.info "Action Verbs: #{has_action_verbs ? '+2' : '+0'}"
      Rails.logger.info "Impact: #{has_quantitative_impact || has_tech_impact ? '+3' : '+0'}"
      Rails.logger.info "Links: #{has_any_link ? '+2' : '+0'}"
      Rails.logger.info "TOTAL: #{points} / 30"

      reasoning = if problems.any?
        "Issues: #{problems.uniq.join('; ')}."
      else
        "Excellent projects section."
      end

      [points, status, reasoning, { problems: problems.uniq, suggestions: final_suggestions.uniq }]
    end
  end
end
