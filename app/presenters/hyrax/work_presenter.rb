# Generated via
#  `rails generate hyrax:work Work`
module Hyrax
  class WorkPresenter < Hyrax::WorkShowPresenter
    delegate :bibliographic_citation, :date_created_year, :internal_note, to: :solr_document
    
    def json_admin_properties
      #  Admin-only properties to filter from JSON response
      json_properties = %i[
        internal_note
      ]
      current_ability.can?(:edit, id) ? [] : json_properties
    end
    
    def filtered_graph
      if current_ability.can?(:edit, id)
        # provide full graph
        graph
      else
        # Filter admin-only properties from RDF responses
        RDF::Graph.new.insert(*graph.each_statement.to_a.reject { 
          |statement|
          statement.predicate.ends_with?("purl.org/ontology/bibo/Note") || # internal note
          statement.predicate.ends_with?("digital.library.carleton.ca/ns#internal_note") # ditto          
        })   
      end
    end
  end
end
