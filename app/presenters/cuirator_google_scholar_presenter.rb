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

  ## 
  # @return [String] YYYY-formatted publication date
  def etd_publication_date
    etd_date = Array(object.try(:date_created)).first || ''
    etd_date[0,4]
  end
  
end
