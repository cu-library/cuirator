# frozen_string_literal: true
# Set up database with default records for development and testing
# Load seeds with db:seed task or db:reset task (drop, create, and migrate database, then load seeds)
abort("The Rails environment is running in production mode!") if Rails.env.production?

# Load admin set
admin_set_id = AdminSet.find_or_create_default_admin_set_id
# @todo add library-staff group as managers on default admin setn

# Create roles
admin_role = Role.find_or_create_by(name: Hyrax.config.admin_user_group_name)
staff_role = Role.find_or_create_by(name: 'library-staff')

# Create users
admin_user = User.find_or_create_by(email: 'admin_user@example.com') { |user| user.password = 'admin_password' }
staff_user = User.find_or_create_by(email: 'staff_user@example.com') { |user| user.password = 'staff_password' }
basic_user = User.find_or_create_by(email: 'basic_user@example.com') { |user| user.password = 'basic_password' }

# Assign users to roles
admin_role.users << admin_user
staff_role.users << staff_user

puts "Seeded database '#{Rails.configuration.database_configuration[Rails.env.to_s]["database"]}'"
