# Generated via
#  `rails generate hyrax:work ResearchWork`
module Hyrax
  # Generated controller for ResearchWork
  class ResearchWorksController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::ResearchWork

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ResearchWorkPresenter
  end
end
