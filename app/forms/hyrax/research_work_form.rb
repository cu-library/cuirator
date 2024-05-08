# Generated via
#  `rails generate hyrax:work ResearchWork`
module Hyrax
  # Generated form for ResearchWork
  class ResearchWorkForm < Hyrax::Forms::WorkForm
    self.model_class = ::ResearchWork
    self.terms += [:resource_type, :internal_note]

    # Bulkrax uses source field to store identifiers used in
    # import / export jobs. Bulkrax identifiers should only
    # be updated by import / export jobs. Drop field from form. 
    self.terms -= [:source]

    # Update required fields: drop Rights Statement, add Resource Type
    self.required_fields += [:resource_type]
    self.required_fields -= [:rights_statement]

  end
end
