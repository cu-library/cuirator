# frozen_string_literal: true

class SolrDocument
  include Blacklight::Solr::Document
  include BlacklightOaiProvider::SolrDocument

  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # Ssemantic field mappings below are used to assemble OAI-compliant DC or ETDMS
  # documents, as requested. Fields may be multi or single valued.
  # See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  use_extension(Blacklight::Document::DublinCore)
  use_extension(Blacklight::Document::Etdms)

  # Do content negotiation for AF models.
  use_extension(Hydra::ContentNegotiation)

  # Get YYYY date created for all work types
  def date_created_year
    self['date_created_year_ssim']
  end

  # Get citation field for Work, Research Work work types
  def bibliographic_citation
    self['bibliographic_citation_tesim']
  end

  # Get degree fields for ETD work type
  def degree_level
    self['degree_level_tesim']
  end

  def degree
    self['degree_tesim']
  end

  def degree_discipline
    self['degree_discipline_tesim']
  end

  def internal_note
    self['internal_note_tesim']
  end

  def agreement
    self['agreement_tesim']
  end

  # OAI Metadata fields
  # Element names &  mappings can be shared by Dublin Core and ETDMS formats
  # See Blacklight::Document::DublinCore and Blacklight::Document::Etdms for XML exporters
  field_semantics.merge!(
    title: 'title_tesim',
    creator: 'creator_tesim',
    contributor: 'contributor_tesim',
    subject: %w[subject_tesim keyword_tesim],
    description: %w[description_tesim abstract_tesim],
    publisher: 'publisher_tesim',
    type: 'resource_type_tesim',
    language: 'language_tesim',
    rights: %w[license_tesim rights_notes_tesim rights_statement_tesim],
    relation: 'related_url_tesim',
    # ETDMS-specific elements
    name: 'degree_tesim',
    discipline: 'degree_discipline_tesim',
    # ... degree grantor is available from publisher
    grantor: 'publisher_tesim',
    # ... and override hash key for degree level
    level: 'oai_etdms_level',
    # Override hash keys for shared elements date and identifier
    date: 'oai_date',
    identifier: %w[identifier_tesim oai_identifier],
    # ... and create a *special* element to hold file URLs as identifiers in ETDMS records but not DC
    oai_etdms_identifier: 'oai_etdms_identifier'
  )

  # Override SolrDocument hash access to provide custom values in OAI fields
  def [](key)
    return send(key) if %w[oai_etdms_level oai_date oai_identifier oai_etdms_identifier].include?(key)

    super
  end

  # Provide label for degree level authority
  def oai_etdms_level
    return unless self['has_model_ssim'].first == 'Etd'

    # Degree Level is required & allows a single value.
    ::DegreeLevelsService.label(self['degree_level_tesim'].first)
  end

  # Provide correct date format for different work types
  def oai_date
    # if ETD, use YYYY date
    self['has_model_ssim'].first == 'Etd' ? self['date_created_year_ssim'] : self['date_created_tesim']
  end

  # Include collection & work URLs in dc:identifier
  def oai_identifier
    url_vars = { only_path: false, action: 'show', host: hyrax_host,
                 controller: "hyrax/#{self['has_model_ssim'].first.underscore.pluralize}",
                 id: id }

    if self['has_model_ssim'].first == 'Collection'
      # Return collection URL
      Hyrax::Engine.routes.url_helpers.url_for(url_vars)
    else
      # Return work URL
      Rails.application.routes.url_helpers.url_for(url_vars)
    end
  end

  # LAC requires OAI-ETDMS requires file download URLs in identifier element.
  # LAC requiresd download URLs with a file extension. Add file extension based
  # on mimetype.
  def oai_etdms_identifier
    return unless self['has_model_ssim'].first == 'Etd'

    # Support PDFs & ZIPs file formats expected in transfer and warn about anything else
    mime_types = { 'application/pdf' => 'pdf', 'application/zip' => 'zip' }

    self['file_set_ids_ssim']&.map do |fs_id|
      # Fetch FileSet metadata from Solr
      fs = Hyrax::SolrService.search_by_id(fs_id)
      next unless fs['visibility_ssi'] == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

      fs_ext = mime_types[fs_mime_type] ? ".#{mime_types[fs_mime_type]}" : ''
      Hyrax.logger.warn("SolrDocument::oai_etdmds_identifer - unknown mime type #{fs_mime_type}") unless fs_ext

      # append extension to download URL
      Hyrax::Engine.routes.url_helpers.download_url(fs_id, host: hyrax_host) + fs_ext
    end
  end

  # Return an ETDMS representation of the document. Required by ruby-oai.
  # See lib/oai/provider/response/list_metadata_formats.rb:record_supports
  def to_oai_etdms
    export_as(:etdms_xml)
  end

  private

  def hyrax_host
    CatalogController.blacklight_config.oai[:provider][:repository_url].gsub('/catalog/oai', '')
  end
end
