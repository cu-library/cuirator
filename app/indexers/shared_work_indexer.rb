# frozen_string_literal: true

# Custom indexing behaviour shared by all work types
class SharedWorkIndexer < Hyrax::WorkIndexer
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
      # store YYYY-formatted year
      solr_doc['date_created_year_ssim'] = object.date_created.map { |value| date_created_year(value) }

      # Index OAI set membership based on collection names & valid as set specs (spaces aren't valid)
      solr_doc['member_of_oai_sets_ssim'] = object.member_of_collections.map do |collection|
        # Join titles into a workable set spec / name.
        collection.title.join(' ').strip.gsub(/\s+/, '_')
      end

      # Index all parent collections for nesting
      index_parent_collections(solr_doc)
    end
  end
end
