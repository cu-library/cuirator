# Generated via
#  `rails generate hyrax:work ResearchWork`
module Hyrax
  class ResearchWorkPresenter < Hyrax::WorkShowPresenter
    delegate :bibliographic_citation, :date_created_year, to: :solr_document
  end
end
