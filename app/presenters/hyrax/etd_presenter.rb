# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  class EtdPresenter < Hyrax::WorkShowPresenter
    delegate :degree_level, :degree, :degree_discipline, :internal_note, to: :solr_document
  end
end
