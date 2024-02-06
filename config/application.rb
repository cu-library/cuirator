require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Cuirator
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Add custom error pages
    config.exceptions_app = self.routes

    # Set default locale
    config.i18n.default_locale = :en

    # Handle unsupported locales in application controller
    # Currently, only default locale :en is supported. Add to list to support additional locales.
   config.i18n.available_locales = [ I18n.default_locale ]

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Load override files
    # see https://edgeguides.rubyonrails.org/engines.html#overriding-models-and-controllers
    # code from https://github.com/UNC-Libraries/hy-c/blob/main/config/application.rb
    overrides = "#{Rails.root}/app/overrides"
    config.to_prepare do
      Dir.glob("#{overrides}/**/*_override.rb").sort.each do |c|
      Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end
  end
end
