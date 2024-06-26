# Generated via
#  `rails generate hyrax:work Work`
module Hyrax
  # Generated form for Work
  class WorkForm < Hyrax::Forms::WorkForm
    self.model_class = ::Work
    self.terms += [:resource_type, :internal_note]
    # Bulkrax uses the source field to store identifiers used in import/export
    self.terms -= [:source]
    self.required_fields = [:title, :resource_type]
  end
end
