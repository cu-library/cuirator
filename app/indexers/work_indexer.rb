# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Work`
class WorkIndexer < SharedWorkIndexer
  # Uncomment to add indexing behaviour specific to generic Works
  # def generate_solr_document
  #   super.tap do |solr_doc|
  #     solr_doc['my_custom_field_ssim'] = object.my_custom_property
  #   end
  # end
end
