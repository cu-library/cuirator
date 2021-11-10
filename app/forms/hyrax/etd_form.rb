# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  # Generated form for Etd
  class EtdForm < Hyrax::Forms::WorkForm
    self.model_class = ::Etd
    self.terms += [:resource_type, :degree_level, :degree, :degree_discipline, :internal_note]
    self.required_fields -= [:rights_statement]
    self.required_fields += [:resource_type, :degree_level, :degree, :degree_discipline]
   end
end
