# frozen_string_literal: true
# Set up database with default users, roles, and permissions for development and testing
# Load seeds with db:seed task or db:reset task (drop, create, and migrate database, then load seeds)
abort("The Rails environment is running in production mode!") if Rails.env.production?

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

# Create default admin set
admin_set = Hyrax::AdminSetCreateService.find_or_create_default_admin_set

# Update role permissions on default admin set
permission_template = Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set.id.to_s)

# Remove registered users as depositors
permission_template.access_grants.find_by(agent_type: 'group', agent_id: 'registered', access: 'deposit').delete

# Add group library-staff to participants on default admin set, with 'manage' access
Hyrax::PermissionTemplateAccess.create(
  permission_template: permission_template,
  agent_type: 'group',
  agent_id: 'library-staff',
  access: 'manage'
)

puts "Seeded database '#{Rails.configuration.database_configuration[Rails.env.to_s]["database"]}'"
