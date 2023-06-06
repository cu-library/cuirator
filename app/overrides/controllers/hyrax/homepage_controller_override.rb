# frozen_string_literal: true
# https://github.com/samvera/hyrax/blob/hyrax-v3.5.0/app/controllers/hyrax/homepage_controller.rb
Hyrax::HomepageController.class_eval do
 
  # Override collections method to sort by date last modified
  def collections(rows: 5)
    Hyrax::CollectionsService.new(self).search_results do |builder|
      builder.rows(rows)
      builder.merge(sort: "system_modified_dtsi desc")
    end
  rescue Blacklight::Exceptions::ECONNREFUSED, Blacklight::Exceptions::InvalidRequest
    []
  end

end
