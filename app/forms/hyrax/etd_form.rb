# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  # Generated form for Etd
  class EtdForm < Hyrax::Forms::WorkForm
    self.model_class = ::Etd
    self.terms += [:resource_type, :degree_level, :degree, :degree_discipline, :internal_note, :agreement]

    # Remove source field from form: used by Bulkrax to store import / export identifiers for a work
    self.terms -= [:source]

    # Drop requirement for rights statement. Use rights statement and/or rights notes, as appropriate. 
    self.required_fields -= [:rights_statement]

    # Add required thesis fields 
    # Note: Agreement is a required field in materials transferred from FGPA - if not present, thesis
    # will not be processed. However, agreements are not available for theses published before the 
    # automated deposit from FGPA was put in place. Agreements must be an optional field to allow editing
    # of theses acquired before the automated deposit.
    self.required_fields += [:resource_type, :degree_level, :degree, :degree_discipline]
   end
end
