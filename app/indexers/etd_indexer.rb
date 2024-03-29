# Generated via
#  `rails generate hyrax:work Etd`
class EtdIndexer < Hyrax::WorkIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  # Index an object's top-level parent collection(s)
  include ParentCollectionBehavior

  # Use date parsing helper in HyraxHelper
  include HyraxHelper

  # Uncomment this block if you want to add custom indexing behavior:
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['date_created_year_ssim'] = object.date_created.map { |value| date_created_year(value) }
      solr_doc = index_parent_collections(solr_doc)
    end
  end
end
