# Generated via
#  `rails generate hyrax:work ResearchWork`
module Hyrax
  class ResearchWorkPresenter < Hyrax::WorkShowPresenter
    delegate :bibliographic_citation, :date_created_year, :internal_note, to: :solr_document 
  end
end
