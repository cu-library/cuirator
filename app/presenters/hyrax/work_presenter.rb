# Generated via
#  `rails generate hyrax:work Work`
module Hyrax
  class WorkPresenter < Hyrax::WorkShowPresenter
    delegate :bibliographic_citation, :date_created_year, to: :solr_document
  end
end
