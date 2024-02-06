class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior

  # Adds Hyrax behaviors into the application controller
  include Hyrax::Controller
  include Hyrax::ThemedLayoutController
  with_themed_layout '1_column'

  # Override set_locale in app/controllers/concerns/hyrax/controller.rb
  # Permitted locales set in config/application.rb
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
   rescue I18n::InvalidLocale
    I18n.locale = I18n.default_locale
  end
  
end
