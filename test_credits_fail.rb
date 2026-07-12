user = User.find_by(email: 'test@example.com') || User.first
resume = user.resumes.last
credits_before = user.remaining_credits.to_i

puts "CREDITS BEFORE: #{credits_before}"

begin
  AiService.generate(user: user, resume: resume, feature: "resume_summary", instructions: "test fail") do |text|
    puts "Inside block... raising error to trigger rollback."
    raise "Simulated Validation Failure"
  end
rescue => e
  puts "Expected Error: #{e.message}"
end

user.reload
credits_after = user.remaining_credits.to_i
puts "CREDITS AFTER: #{credits_after}"
puts credits_before == credits_after ? "SUCCESS: Credits not deducted on error." : "FAILURE: Credits were deducted!"

