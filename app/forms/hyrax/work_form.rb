# Generated via
#  `rails generate hyrax:work Work`
module Hyrax
  # Generated form for Work
  class WorkForm < Hyrax::Forms::WorkForm
    self.model_class = ::Work
    self.terms += [:resource_type, :bibliographic_citation]
    self.required_fields = [:title, :creator, :resource_type]
  end
end
