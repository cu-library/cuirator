# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  # Generated controller for Etd
  class EtdsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Etd

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::EtdPresenter

    # Finds a solr document matching the id and sets @presenter
    # @raise CanCan::AccessDenied if the document is not found or the user doesn't have access to it.
    # rubocop:disable Metrics/AbcSize
    def show
      @user_collections = user_collections

      respond_to do |wants|
        wants.html { presenter && parent_presenter }
        if current_ability.admin? then
          wants.json do
            # load @curation_concern manually because it's skipped for html
            @curation_concern = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: params[:id])
            curation_concern # This is here for authorization checks (we could add authorize! but let's use the same method for CanCanCan)
            render :show, status: :ok
          end
          additional_response_formats(wants)
          wants.ttl { render body: presenter.export_as_ttl, mime_type: Mime[:ttl] }
          wants.jsonld { render body: presenter.export_as_jsonld, mime_type: Mime[:jsonld] }
          wants.nt { render body: presenter.export_as_nt, mime_type: Mime[:nt] }
        end
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
