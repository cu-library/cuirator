# Generated via
#  `rails generate hyrax:work Etd`
class Etd < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = EtdIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # RDF expression of ETDMS is planned but not yet available. Use locally defined URI predicates for now
  property :degree_level, predicate: ::RDF::URI.new("http://www.ndltd.org/standards/metadata/etdms/1.1/level"), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :degree, predicate: ::RDF::URI.new("http://www.ndltd.org/standards/metadata/etdms/1.1/name"), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :degree_discipline, predicate: ::RDF::URI.new("http://www.ndltd.org/standards/metadata/etdms/1.1/discipline"), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  # Use Note predicate from DCMI BIBO schema to capture internal notes about changes to ETDs
  property :internal_note, predicate: ::RDF::Vocab::BIBO.Note, multiple: true do |index|
    index.as :stored_searchable
  end

  # Use License predicate from Schema.org for Agreements accepted by authors during ETD submission
  property :agreement, predicate: ::RDF::Vocab::SCHEMA.license, multiple: true do |index|
    index.as :stored_searchable
  end
  
  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
