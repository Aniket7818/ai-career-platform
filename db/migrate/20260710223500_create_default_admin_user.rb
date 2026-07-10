class CreateDefaultAdminUser < ActiveRecord::Migration[7.2]
  def up
    email = ENV['ADMIN_EMAIL'] || 'ajitaniket956556@gmail.com'
    password = ENV['ADMIN_PASSWORD'] || 'Aniket0987'
    unless User.exists?(email: email)
      User.create!(
        email: email,
        password: password,
        password_confirmation: password,
        first_name: 'Aniket',
        last_name: 'Ajit',
        username: 'aniket_admin',
        role: 'admin',
        status: 'active',
        confirmed_at: Time.current
      )
    end
  end

  def down
    # We do not destroy the user on down migration to prevent accidental deletion of administrative data
  end
end
