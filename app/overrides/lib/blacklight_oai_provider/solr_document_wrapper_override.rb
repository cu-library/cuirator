# frozen_string_literal: true

# Override blacklight_oai_provider/lib/blacklight_oai_provider/solr_document_wrapper.rb
# Add metadata format filters defined in OAI config to queries to filter search results
BlacklightOaiProvider::SolrDocumentWrapper.class_eval do
  # Override BlacklightOaiProvider::SolrDocumentWrapper.find to apply format filters to single-record queries
  def find(selector, options = {})
    return next_set(options[:resumption_token]) if options[:resumption_token]

    if selector == :all
      response = search_service.repository.search(conditions(options))

      if limit && response.total > limit
        return select_partial(BlacklightOaiProvider::ResumptionToken.new(options.merge(last: 0), nil, response.total))
      end

      response.documents
    else
      query = search_service.search_builder.where(id: selector).query
      response = search_service.repository.search(query).documents

      # If no documents in response, id is invalid
      raise OAI::IdException if response.empty?

      # append format filters defined in OAI config as filter queries
      format_filters(options).each { |fq| query.append_filter_query(fq) }

      # Search again. If still no search result, record can't be disseminated in selected format
      response = search_service.repository.search(query).documents
      raise OAI::FormatException if response.empty?

      # Return best match, or nil & let the exception handler deal with it
      response.first
    end
  end

  # Override BlacklightOaiProvider::SolrDocumentWrapper.conditions to include format filters in conditions
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

    # append format filters defined in OAI config as filter queries
    format_filters(constraints).each { |fq| query.append_filter_query(fq) }

    # append set filter if present
    query.append_filter_query(@set.from_spec(constraints[:set])) if constraints[:set].present?
    query
  end

  private

  def format_filters(options)
    return [] unless options[:metadata_prefix].present?

    # get format filters defined in OAI config, if any, or return an empty list
    @controller.blacklight_config.oai.dig(:document, :format_filters, options[:metadata_prefix].to_sym) || []
  end
end
