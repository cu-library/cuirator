# frozen_string_literal: true
module Cuirator
  ##
  # Handles presentation for google scholar meta tags 
  # extended to support Etd-specific meta tags
  class GoogleScholarPresenter < Hyrax::GoogleScholarPresenter

    ##
    # @return [String] work type 
    def work_type
      Array(object.try(:human_readable_type)).first || ''
    end

    ##
    # @return [String] YYYY-formatted publication date
    def publication_date_year
      Array(object.try(:date_created_year)).first || ''
    end

  end
end