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
    
    def filtered_graph
      if current_ability.can?(:write, id)
        # provide full graph
        graph
      else
        # Filter admin-only properties from RDF responses
        RDF::Graph.new.insert(*graph.each_statement.to_a.reject { 
          |statement|
          statement.predicate.ends_with?("purl.org/ontology/bibo/Note") || # internal note
          statement.predicate.ends_with?("schema.org/license") ||          # student agreement
          statement.predicate.ends_with?("digital.library.carleton.ca/ns#agreement") ||  # ETD - old predicate
          statement.predicate.ends_with?("digital.library.carleton.ca/ns#internal_note") # ditto          
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
