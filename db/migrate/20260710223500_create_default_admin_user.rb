class CreateDefaultAdminUser < ActiveRecord::Migration[7.2]
  def up
    email = 'ajitaniket956556@gmail.com'
    unless User.exists?(email: email)
      User.create!(
        email: email,
        password: 'Aniket0987',
        password_confirmation: 'Aniket0987',
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
