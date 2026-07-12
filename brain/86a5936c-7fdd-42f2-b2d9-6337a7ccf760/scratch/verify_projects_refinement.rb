require_relative '../../../../../Desktop/Projects/careerai-ai-v2/config/environment'

def run_test(name, projects)
  puts "\n=========================================="
  puts "RUNNING QA TEST: #{name}"
  puts "=========================================="
  
  # Mock a resume object
  resume = Struct.new(:content).new({ 'projects' => projects })
  checker = ScoreEngine::ContentCompletenessChecker.new(resume)
  
  # Evaluate the projects section
  status, points, reasoning, meta = checker.send(:evaluate_section, 'projects')
  
  puts "Status: #{status}"
  puts "Points: #{points} / 30"
  puts "Problems Found: #{meta[:problems]}"
  puts "Suggestions:"
  meta[:suggestions].each { |s| puts "  - #{s}" }
end

# ────────────────────────────────────────────────────────
# Test A: 30/30 (Perfect projects section)
# Expected: Only optional growth suggestions.
# ────────────────────────────────────────────────────────
test_a_projects = [
  {
    'projectName' => 'Portfolio Website',
    'technologies' => 'HTML, CSS, JavaScript',
    'description' => 'Built a responsive personal portfolio website to showcase projects and skills. Designed multiple pages with responsive layouts and contact form. Added authentication.',
    'projectLink' => 'github.com/user/portfolio'
  },
  {
    'projectName' => 'E-commerce Platform',
    'technologies' => 'React, Ruby on Rails, Redis',
    'description' => 'Developed an e-commerce platform with Redis caching. Handled queue processing and background jobs for stripe payment gateway.',
    'projectLink' => 'www.google.com'
  }
]
run_test("Test A (30/30 Perfect Section)", test_a_projects)

# ────────────────────────────────────────────────────────
# Test B: Missing links
# Expected: Only link suggestion.
# ────────────────────────────────────────────────────────
test_b_projects = [
  {
    'projectName' => 'Portfolio Website',
    'technologies' => 'HTML, CSS, JavaScript',
    'description' => 'Built a responsive personal portfolio website to showcase projects and skills. Designed multiple pages with responsive layouts and contact form. Added authentication.',
    'projectLink' => ''
  },
  {
    'projectName' => 'E-commerce Platform',
    'technologies' => 'React, Ruby on Rails, Redis',
    'description' => 'Developed an e-commerce platform with Redis caching. Handled queue processing and background jobs for stripe payment gateway.',
    'projectLink' => ''
  }
]
run_test("Test B (Missing links only)", test_b_projects)

# ────────────────────────────────────────────────────────
# Test C: Missing impact
# Expected: Only impact suggestion.
# ────────────────────────────────────────────────────────
test_c_projects = [
  {
    'projectName' => 'Portfolio Website',
    'technologies' => 'HTML, CSS, JavaScript',
    'description' => 'Built a layout for a personal website.',
    'projectLink' => 'github.com/user/portfolio'
  },
  {
    'projectName' => 'E-commerce Platform',
    'technologies' => 'React, Ruby on Rails, PostgreSQL',
    'description' => 'Developed an e-commerce platform.',
    'projectLink' => 'www.google.com'
  }
]
# Wait, Test C needs all other categories to have full points except impact.
# If they get full points for count, titles, desc length, tech, verbs, links:
# count = 2 (10 pts)
# titles = valid (3 pts)
# desc length = 100+ (5 pts)
# tech = 3+ (4 pts)
# impl = true (3 pts)
# verbs = true (2 pts)
# links = valid (2 pts)
# Total points = 29/30 (if impact is missing, points should be 26/30 complete).
# Let's adjust descriptions so they have action verbs and implementation details (e.g. Built, Developed, responsive, dashboard, api, crud) but NO impact/tech achievements (no jwt, caching, redis, auth, users, etc.).
test_c_projects_isolated = [
  {
    'projectName' => 'Portfolio Website',
    'technologies' => 'HTML, CSS, JavaScript',
    'description' => 'Built a responsive personal portfolio website to showcase projects and skills. Designed multiple pages with responsive layouts and contact form.',
    'projectLink' => 'github.com/user/portfolio'
  },
  {
    'projectName' => 'E-commerce Platform',
    'technologies' => 'React, Express, PostgreSQL',
    'description' => 'Developed an e-commerce platform. Designed dashboard and api endpoints with crud functionality.',
    'projectLink' => 'www.google.com'
  }
]
run_test("Test C (Missing impact only)", test_c_projects_isolated)

# ────────────────────────────────────────────────────────
# Test D: Missing implementation
# Expected: Only implementation suggestion.
# ────────────────────────────────────────────────────────
# Count = 2 (10)
# Titles = valid (3)
# Desc length = 100+ (5)
# Tech = 3+ (4)
# Action verbs = true (2)
# Impact = true (3) -> e.g. users, downloads, or caching/redis
# Links = valid (2)
# Impl = false (no built, developed, etc. in implementation list, and no bullet points) -> wait, if action verbs is true, they have "Built" or "Developed", which are also implementation keywords.
# Let's see: we can use action verbs but not implementation detail. Wait, action verbs are %w[built developed designed created implemented optimized architected integrated] and impl_keywords are similar.
# Wait, if is_genuinely_minimal is true, it triggers implementation details missing.
# Let's check: if we want ONLY implementation detail suggestion, we can trigger `!has_impl_detail`.
# Let's construct a description: "My website showcases various pages. My project is hosted online. I wrote standard code." (avg_desc_len > 100, but no action verbs or impl details). If we also miss action verbs, it will suggest action verbs.
# To get only implementation suggestion, we can have action verbs but no implementation details. How?
# "Architected clean code. Designed files. Optimized pages. Standardized system." -> Action verbs = true. Impl detail = false!
test_d_projects_isolated = [
  {
    'projectName' => 'Portfolio Website',
    'technologies' => 'HTML, CSS, JavaScript',
    'description' => 'Architected clean code. Designed files. Optimized pages. Standardized system. Architected clean code. Designed files.',
    'projectLink' => 'github.com/user/portfolio'
  },
  {
    'projectName' => 'E-commerce Platform',
    'technologies' => 'React, Express, PostgreSQL',
    'description' => 'Architected clean code. Designed files. Optimized pages. Standardized system. Architected clean code. Designed files.',
    'projectLink' => 'www.google.com'
  }
]
run_test("Test D (Missing implementation only)", test_d_projects_isolated)

# ────────────────────────────────────────────────────────
# Test E: One project only
# Expected: Only "Add another project" suggestion.
# ────────────────────────────────────────────────────────
test_e_projects = [
  {
    'projectName' => 'Portfolio Website',
    'technologies' => 'HTML, CSS, JavaScript',
    'description' => 'Built a responsive personal portfolio website to showcase projects and skills. Designed multiple pages with responsive layouts and contact form. Added authentication.',
    'projectLink' => 'github.com/user/portfolio'
  }
]
run_test("Test E (One project only)", test_e_projects)
