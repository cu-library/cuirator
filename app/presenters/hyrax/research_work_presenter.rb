# Generated via
#  `rails generate hyrax:work ResearchWork`
module Hyrax
  class ResearchWorkPresenter < Hyrax::WorkShowPresenter
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
          statement.predicate.ends_with?("purl.org/ontology/bibo/Note") || 
          statement.predicate.ends_with?("schema.org/license") ||          
          statement.predicate.ends_with?("digital.library.carleton.ca/ns#internal_note") 
        })   
      end
    end

    def export_as_nt
      filtered_graph.dump(:ntriples)
    end

    def export_as_jsonld
      filtered_graph.dump(:jsonld, standard_prefixes: true)
    end

    def export_as_ttl
      filtered_graph.dump(:ttl)
    end

  end

end
