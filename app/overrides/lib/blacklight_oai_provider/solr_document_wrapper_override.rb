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
    # Published before CURVE automated deposit OR (licenced to Carleton AND LAC)
    # "(#{pre_curve_fq}) OR (#{carleton_fq} AND #{lac_fq})"
    # ... but Solr probs -- boolean expr w/ negative clause - see 
    # https://cwiki.apache.org/confluence/display/solr/FAQ#FAQ-Whydoes'fooAND-baz'matchdocs,but'fooAND(-bar)'doesn't?

    # for now return explicitly-licenced theses
    "#{carleton_fq} AND #{lac_fq}"
  end

  def pre_curve_fq
    # Pre-CURVE theses have no agreements
    '-agreement_tesim:[* TO *]'
  end

  def carleton_fq
    # Author has accepted current / previous CU Thesis Licence Agreement
    # See config/authorities/agreements.yml
    '(agreement_tesim:"https://repository.library.carleton.ca/concern/works/pc289j04q" '\
      'OR agreement_tesim:"https://repository.library.carleton.ca/concern/works/ng451h485")'
  end

  def lac_fq
    # Author has accepted current / previous LAC agreement
    # See config/authorities/agreements.yml
    '(agreement_tesim:"https://repository.library.carleton.ca/concern/works/6h440t871" ' \
      'OR agreement_tesim:"https://repository.library.carleton.ca/concern/works/tt44pm84n")'
  end
end
