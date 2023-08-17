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

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models. 

  use_extension( Hydra::ContentNegotiation )

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

  # OAI Metadata fields (DC only)
  field_semantics.merge!(
    title: "title_tesim",
    creator: "creator_tesim",
    subject: "subject_tesim",
    description: ["description_tesim", "abstract_tesim"],
    publisher: "publisher_tesim",
    contributor: "contributor_tesim",
    date: "date_tesim",
    type: "resource_type_tesim",
    identifier: "identifier_tesim",
    language: "language_tesim",
    rights: ["rights_statement_tesim", "rights_notes_tesim"],
    relation: "related_url_tesim",
    source: "bibliographic_citation_tesim"
  )

end
