# frozen_string_literal: true

##
# Local presentation for google scholar meta tags
#
# See Hyrax::GoogleScholarPresenter for details
#
class CuiratorGoogleScholarPresenter < Hyrax::GoogleScholarPresenter

  def etd?
    return object.etd? if object.respond_to?(:etd?)
  end

end
