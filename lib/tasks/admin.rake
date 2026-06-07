namespace :admin do
  desc "Create super admin user"

  task create: :environment do
    user = User.find_or_initialize_by(email: "aniket1@gmail.com")

    user.username = "aniket"
    user.first_name = "Aniket"
    user.password = "aniket123"
    user.password_confirmation = "aniket123"
    user.role = "super_admin"
    user.status = "active"
    user.verified_at ||= Time.current

    user.save!

    puts "=================================="
    puts "Super Admin Created Successfully"
    puts "Username: aniket"
    puts "Email: aniket1@gmail.com"
    puts "Password: aniket123"
    puts "=================================="
  end
end
