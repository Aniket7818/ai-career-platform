user = User.find_by(email: 'test@example.com') || User.first
resume = user.resumes.last
credits_before = user.remaining_credits.to_i

puts "CREDITS BEFORE: #{credits_before}"

begin
  AiOptimizationService.optimize(resume, "invalid_action", { instructions: "fake" })
rescue => e
  puts "Expected Error: #{e.message}"
end

user.reload
credits_after = user.remaining_credits.to_i
puts "CREDITS AFTER: #{credits_after}"
puts credits_before == credits_after ? "SUCCESS: Credits not deducted on error." : "FAILURE: Credits were deducted!"

begin
  # This one should deduct
  result = AiOptimizationService.optimize(resume, "generate_summary", { instructions: "Test instructions" })
  puts "Generate summary successful."
rescue => e
  puts "Error: #{e.message}"
end

user.reload
credits_after_success = user.remaining_credits.to_i
puts "CREDITS AFTER SUCCESS: #{credits_after_success}"
puts credits_after_success < credits_after ? "SUCCESS: Credits were deducted." : "FAILURE: Credits were not deducted!"
