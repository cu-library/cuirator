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
  def set_locale
    locale_check = params[:locale] || I18n.default_locale

    if I18n.available_locales.include?(locale_check.to_sym)
      I18n.locale = locale_check
    else
      redirect_to "#{request.path}?locale=en"
    end
  end
end
