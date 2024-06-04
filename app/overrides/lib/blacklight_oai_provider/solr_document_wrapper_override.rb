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

    if constraints[:metadata_prefix].present? && constraints[:metadata_prefix] == 'oai_etdms'
      # Disseminate over OAI if thesis and licenced for harvesting by LAC
      query.append_filter_query(thesis_fq)
      query.append_filter_query(licenced_fq)
    end

    query.append_filter_query(@set.from_spec(constraints[:set])) if constraints[:set].present?
    query
  end

  private

  def thesis_fq
    'has_model_ssim:Etd'
  end

  def licenced_fq
    # Filter out any works that have a Carleton University thesis licence
    # agreement but do not have any of the current / former LAC agreements
    # See config/authorities/agreements.yml

    # Filter OUT any theses that:
    # HAVE either CU TLA, or older Licence to Carleton University
    # DO NOT HAVE current (2020-2025) or former (2015-2020) LAC licence
    '-agreement_tesim:(+(pc289j04q OR ng451h485) -tt44pm84n -6h440t871)'
  end
end
