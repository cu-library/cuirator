Hydra::ContentNegotiation.class_eval do
    # Override JSON-LD, ttl & nt requests on catalogue
    # to filter out limited-access statements
    def export_as_nt
      filtered_graph.dump(:ntriples)
    end
  
    def export_as_jsonld
      filtered_graph.dump(:jsonld, :standard_prefixes => true)
    end
  
    def export_as_ttl
      filtered_graph.dump(:ttl)
    end
  
    def filtered_graph
      # Filter admin-only properties from RDF responses
      RDF::Graph.new.insert(*clean_graph.each_statement.to_a.reject { 
        |statement|
        statement.predicate.ends_with?("purl.org/ontology/bibo/Note") ||               # ETD internal note
        statement.predicate.ends_with?("schema.org/license") ||                        # ETD student agreement
        statement.predicate.ends_with?("digital.library.carleton.ca/ns#agreement") ||  # ETD - old predicate
        statement.predicate.ends_with?("digital.library.carleton.ca/ns#internal_note") # ditto
      })  
    end
  
  end