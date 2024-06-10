# frozen_string_literal: true

# Override blacklight_oai_provider/lib/blacklight_oai_provider/solr_document_wrapper.rb
# If metadata format is oai_etdms, add conditions to query
BlacklightOaiProvider::SolrDocumentWrapper.class_eval do
  def conditions(constraints)
    query = search_service.search_builder.merge(sort: "#{solr_timestamp} asc", rows: limit).query

    if constraints[:from].present? || constraints[:until].present?
      from_val = solr_date(constraints[:from])
      to_val = solr_date(constraints[:until], true)
      if from_val == to_val
        query.append_filter_query("#{solr_timestamp}:\"#{from_val}\"")
      else
        query.append_filter_query("#{solr_timestamp}:[#{from_val} TO #{to_val}]")
      end
    end

    if constraints[:metadata_prefix].present?
      # append format filters defined in OAI config as filter queries
      @controller.blacklight_config.oai.dig(:document, :format_filters,
                                            constraints[:metadata_prefix].to_sym)&.each do |fq|
        query.append_filter_query(fq)
      end
    end

    query.append_filter_query(@set.from_spec(constraints[:set])) if constraints[:set].present?
    query
  end
end
