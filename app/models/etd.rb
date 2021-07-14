# Generated via
#  `rails generate hyrax:work Etd`
class Etd < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = EtdIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # @todo use better URIs, check other ETDMS sources
  property :degree_level, predicate: ::RDF::URI.new("http://digital.library.carleton.ca/ns#degree_level"), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :degree, predicate: ::RDF::URI.new("http://digital.library.carleton.ca/ns#degree"), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :degree_discipline, predicate: ::RDF::URI.new("http://digital.library.carleton.ca/ns#degree_discipline"), multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
