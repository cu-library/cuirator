# Generated via
#  `rails generate hyrax:work ResearchWork`
module Hyrax
  class ResearchWorkPresenter < Hyrax::WorkShowPresenter
    delegate :bibliographic_citation, to: :solr_document
  end
end
