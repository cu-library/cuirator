# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'

require 'capybara/rspec'
require 'selenium-webdriver'
require 'webdrivers/chromedriver'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'

# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # Set up environment before running tests
  config.before(:suite) do
    Rails.application.load_tasks
    Rake::Task['db:reset'].invoke

    # reset Fedora and Solr
    ActiveFedora::Cleaner.clean!

    # create default admin set
    Rake::Task['hyrax:default_admin_set:create'].invoke

    # Create admin role, admin user, and no-auth users
    # For now, use methods in hyrax/app/utils/hyrax/test_data_seeders/user_seeder.rb
    # Although we may need to create users & roles directly, when testing Library roles

    # In hyrax-v3.5.0 branch, admin role must exist before generating admin user
    # Changes in hyrax-v4.0.0 branch will make this step unnecessary
    # See https://github.com/samvera/hyrax/blob/hyrax-v3.5.0/app/utils/hyrax/test_data_seeders/user_seeder.rb#L28
    # vs https://github.com/samvera/hyrax/blob/hyrax-v4.0.0/app/utils/hyrax/test_data_seeders/user_seeder.rb#L28
    admin_role ||= Role.find_or_create_by(name: Hyrax.config.admin_user_group_name)

    # Generate admin & basic users
    Hyrax::TestDataSeeders::UserSeeder.generate_seeds
  end

end
