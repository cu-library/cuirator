# frozen_string_literal: true
module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior

  def application_name
    'Digital Collections'
  end

  def institution_name
    'Carleton University Library'
  end

  def  institution_name_full 
    'Carleton University Library'
  end

end
