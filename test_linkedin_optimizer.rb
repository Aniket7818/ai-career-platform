require './config/environment'

def assert(cond, msg = "Assertion failed")
  unless cond
    puts "❌ #{msg}"
    exit 1
  end
  puts "✅ #{msg}"
end

class MockResume
  attr_accessor :content
  def initialize(content)
    @content = content
  end
end

puts "--- Starting LinkedIn Optimizer Backend Tests ---"

# 1. Headline Validation
h_exact = "A" * 220
h_long = "A" * 221

assert(AiOptimizationService.validate_headline_length(h_exact), "Headline of exactly 220 characters should be valid")
assert(!AiOptimizationService.validate_headline_length(h_long), "Headline of 221 characters should be invalid")

# 2. About Section Validation
a_exact = "B" * 2600
a_long = "B" * 2601

assert(AiOptimizationService.validate_about_length(a_exact), "About section of exactly 2600 characters should be valid")
assert(!AiOptimizationService.validate_about_length(a_long), "About section of 2601 characters should be invalid")

# 3. Headline Repair Logic
long_headline_with_separators = (1..6).map { |i| "Segment #{i} with long description and keywords of technology stack #{i * 10}" }.join(" | ")
assert(long_headline_with_separators.length > 220, "Setup: test headline should be > 220 characters")

repaired_headline = AiOptimizationService.repair_headline(long_headline_with_separators)
puts "Original length: #{long_headline_with_separators.length}, Repaired length: #{repaired_headline.length}"
assert(repaired_headline.length <= 220, "Repaired headline must be <= 220 characters")
assert(repaired_headline.include?("Segment 1"), "Repaired headline should preserve original content segments")

# 4. About Section Repair Logic
long_about = (1..15).map { |i| "Paragraph #{i}: " + "This is a detailed paragraph filled with many keywords, achievements, and responsibilities. " * 5 }.join("\n\n")
assert(long_about.length > 2600, "Setup: test about section should be > 2600 characters")

repaired_about = AiOptimizationService.repair_about(long_about)
puts "Original about length: #{long_about.length}, Repaired about length: #{repaired_about.length}"
assert(repaired_about.length <= 2600, "Repaired about section must be <= 2600 characters")
assert(repaired_about.include?("Paragraph 1:"), "Repaired about section should preserve original content paragraphs")

# Setup Resume Context for Grounding
resume_content = {
  "skills" => {
    "languages" => ["Ruby", "Python"],
    "frameworks" => ["Rails", "React"],
    "others" => ["API Development", "Software Engineer", "Web Dev"]
  }
}
mock_resume = MockResume.new(resume_content)

# 5. Full Hash Validation and Repair
dummy_response = {
  "headline_options" => [
    { "type" => "ATS Optimized", "text" => "Short headline" },
    { "type" => "Recruiter Focused", "text" => "Another short headline" },
    { "type" => "Personal Branding", "text" => "Segment 1 | Segment 2 | " + ("Segment 3 " * 20) } # very long
  ],
  "about" => "Introduction paragraph.\n\n" + ("Detailed about body paragraph " * 15) + "\n\nCTA networking paragraph.", # long enough
  "top_technologies" => ["Ruby", "Rails"],
  "core_expertise" => ["API Development"],
  "recruiter_keywords" => ["Software Engineer"],
  "networking_topics" => ["Web Dev"],
  "personal_brand" => "Brand Statement"
}

repaired_hash = AiOptimizationService.validate_and_repair_linkedin(dummy_response, mock_resume)
assert(repaired_hash["headline_options"].is_a?(Array), "repaired headline_options should be an Array")
assert(repaired_hash["headline_options"].size == 3, "should keep the 3 headline options")
assert(repaired_hash["headline_options"][2]["text"].length <= 220, "repaired long headline option must be <= 220 characters")
assert(repaired_hash["about"].length <= 2600, "repaired about section must be <= 2600 characters")
assert(repaired_hash["top_technologies"].include?("Ruby"), "top_technologies array should be preserved/grounded")

# 6. Single Headline Fallback to Multiple Options
dummy_single_response = {
  "headline" => "Single Headline Option | " + ("Extra segment " * 20),
  "about" => "A very long professional about section that exceeds three hundred characters to pass the validation check. It must describe experience, passion, and interest in technology like React, Python, and Software engineering. Therefore, it is guaranteed to satisfy all minimum and maximum length bounds, and we are adding additional text here to make sure it exceeds 300 characters."
}
repaired_single_hash = AiOptimizationService.validate_and_repair_linkedin(dummy_single_response, mock_resume)
assert(repaired_single_hash["headline_options"].is_a?(Array), "should fallback to creating headline_options array")
assert(repaired_single_hash["headline_options"].size == 5, "should fallback to 5 headline options")
assert(repaired_single_hash["headline_options"].all? { |h| h["text"].length <= 220 }, "all fallback headline options must be <= 220 characters")

# 7. JSON Sanitization and Parser Validation
raw_response_with_newlines = <<~TEXT
```json
{
  "headline_options": [
    {
      "type": "ATS Optimized",
      "text": "Software Engineer"
    }
  ],
  "about": "This is a detailed paragraph with literal newlines.
Here is the second line.
And here is a tab:\tHello.",
  "top_technologies": ["Ruby"],
  "core_expertise": ["API Development"],
  "recruiter_keywords": ["Software Engineer"],
  "networking_topics": ["Web Dev"],
  "personal_brand": "Brand Statement"
}
```
TEXT

parsed_from_raw = AiOptimizationService.parse_response(raw_response_with_newlines, "generate_linkedin")
assert(parsed_from_raw.is_a?(Hash), "parse_response should successfully parse JSON even when it contains raw control characters like literal newlines or tabs inside strings")
assert(parsed_from_raw["about"].include?("second line"), "parse_response should preserve the content containing control characters")

puts "--- All Backend LinkedIn Optimizer Tests Passed! 🌟 ---"

