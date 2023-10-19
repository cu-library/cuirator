# frozen_string_literal: true
# Overrides
# https://github.com/samvera/hyrax/blob/hyrax-v3.5.0/app/controllers/concerns/hyrax/works_controller_behavior.rb
# to block access to JSON-LD, TTL & NT responses
Hyrax::WorksControllerBehavior.class_eval do
    # Finds a solr document matching the id and sets @presenter
    # @raise CanCan::AccessDenied if the document is not found or the user doesn't have access to it.
    # rubocop:disable Metrics/AbcSize
    def show
      @user_collections = user_collections

      # Respond to unauthorized requests
      message = I18n.t("hyrax.base.unauthorized.unauthorized")

      respond_to do |wants|
        wants.html { presenter && parent_presenter }
        wants.json do
          # load @curation_concern manually because it's skipped for html
          @curation_concern = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: params[:id])
          curation_concern # This is here for authorization checks (we could add authorize! but let's use the same method for CanCanCan)
          render :show, status: :ok
        end
        additional_response_formats(wants)

        # limit RDF work views
        wants.ttl { render plain: message, status: :unauthorized }
        wants.jsonld { render plain: message, status: :unauthorized }
        wants.nt { render plain: message, status: :unauthorized } 
      end
    end
    # rubocop:enable Metrics/AbcSize 
end
  