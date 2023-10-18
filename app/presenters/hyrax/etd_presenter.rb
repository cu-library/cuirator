# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  class EtdPresenter < Hyrax::WorkShowPresenter
    delegate :degree_level, :degree, :degree_discipline, :internal_note, :agreement, :date_created_year, to: :solr_document

    def json_admin_properties
      #  Admin-only properties to filter from JSON response
      json_properties = %i[
        agreement
        internal_note
      ]
      current_ability.can?(:write, id) ? [] : json_properties
    end
    
  end
end
