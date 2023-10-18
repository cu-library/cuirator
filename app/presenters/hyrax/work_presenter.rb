# Generated via
#  `rails generate hyrax:work Work`
module Hyrax
  class WorkPresenter < Hyrax::WorkShowPresenter
    delegate :bibliographic_citation, :date_created_year, to: :solr_document

    def json_admin_properties
      # Admin-only properties to filter from ResearchWork JSON 
      json_properties = %i[
      ]
    end
    
  end
end
