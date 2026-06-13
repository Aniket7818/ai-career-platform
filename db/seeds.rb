# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


AdminSetting.find_or_create_by!(key: "feature_flags") do |setting|
  setting.value = { ats_checker: true, mock_interview: false, portfolio_generator: false }
end

AdminSetting.find_or_create_by!(key: "maintenance_mode") { |setting| setting.value = { enabled: false } }
AdminSetting.find_or_create_by!(key: "announcements") { |setting| setting.value = { message: "Build resumes faster with polished templates." } }
AdminSetting.find_or_create_by!(key: "pricing_plans") { |setting| setting.value = { free: 0, pro: 499 } }
