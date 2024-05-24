# Generated via
#  `rails generate hyrax:work Work`
class Work < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = WorkIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # Use Note predicate from DCMI BIBO schema to capture internal notes about changes to ETDs
  property :internal_note, predicate: ::RDF::Vocab::BIBO.Note, multiple: true do |index|
    index.as :stored_searchable
  end
  
  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
