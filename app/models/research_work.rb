# Generated via
#  `rails generate hyrax:work ResearchWork`
class ResearchWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = ResearchWorkIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  property :internal_note, predicate: ::RDF::Vocab::MODS::note, multiple: true do |index|
    index.as :stored_searchable
  end
  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
