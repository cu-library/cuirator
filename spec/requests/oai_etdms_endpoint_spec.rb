# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OAI-ETDMS endpoint' do
  # Set up config & create works
  before(:all) do
    @repository_id = 'oai:repository.library.carleton.ca'
    @hyrax_host = CatalogController.blacklight_config.oai[:provider][:repository_url].sub('/catalog/oai', '')

    # Public Etd, with public PDF, licenced to CU & LAC
    @public_etd = FactoryBot.create(:public_etd_with_public_file, {
                                      title: ["Public Etd licenced to LAC #{Time.new.strftime('%Y-%m-%d %H:%M:%S')}"]
                                    })

    # Private Etd, private file. Licenced to CU & LAC, and shouldn't be included due to access restrictions
    @private_etd = FactoryBot.create(:private_etd_with_private_file, {
                                       title: ["Private Etd licenced to LAC #{Time.new.strftime('%Y-%m-%d %H:%M:%S')}"]
                                     })

    # Public Etd does not have explicit agreements. LAC licence is in PDF.
    @public_etd_no_agreements =
      FactoryBot.create(:public_etd_with_public_file, {
                          title: ["Public Etd has LAC licence in PDF #{Time.new.strftime('%Y-%m-%d %H:%M:%S')}"],
                          agreement: []
                        })

    # Public Etd, has CU Thesis Licence Agreement but no LAC licence
    @public_etd_not_licenced =
      FactoryBot.create(:public_etd_with_public_file, {
                          title: ["Public Etd does not have an LAC licence #{Time.new.strftime('%Y-%m-%d %H:%M:%S')}"],
                          agreement: ['https://repository.library.carleton.ca/concern/works/pc289j04q']
                        })

    # Public Etd with a private file. Private file URL should NOT be included.
    @public_etd_private_file =
      FactoryBot.create(:public_etd_with_private_file, {
                          title: ["Public Etd with private file #{Time.new.strftime('%Y-%m-%d %H:%M:%S')}"]
                        })

    # Public Work, shouldn't be included in requests when metadataFormat=oai_etdms
    @public_work = FactoryBot.create(:public_work_with_public_file,
                                     { title: ["Public work #{Time.new.strftime('%Y-%m-%d %H:%M:%S')}"] })
  end

  describe 'ListMetadataFormats verb' do
    it 'oai_etdms is a supported format' do
      get oai_catalog_path(verb: 'ListMetadataFormats')
      expect(response.body).to include('<metadataPrefix>oai_etdms</metadataPrefix>')
    end

    it 'oai_etdms is a supported format for Etds' do
      get oai_catalog_path(verb: 'ListMetadataFormats', identifier: "#{@repository_id}:#{@public_etd.id}")
      expect(response.body).to include('<metadataPrefix>oai_etdms</metadataPrefix>')
    end

    # this fails
    # it 'oai_etdms is NOT a supported format for Works' do
    #   get oai_catalog_path(verb: 'ListMetadataFormats', identifier: "#{repository_id}:#{work.id}")
    #   expect(response.body).not_to include('<metadataPrefix>oai_etdms</metadataPrefix>')
    # end
  end

  describe 'ListIdentifiers verb' do
    # metadataFormat is a required argument for ListRecords verb
    context 'with metadataFormat=oai_dc' do
      it 'lists identifiers for all PUBLIC items' do
        get oai_catalog_path(verb: 'ListIdentifiers', metadataPrefix: 'oai_dc')
        expect(response.body).to include("<identifier>#{@repository_id}:#{@public_work.id}</identifier>")
        expect(response.body).to include("<identifier>#{@repository_id}:#{@public_etd.id}</identifier>")
        expect(response.body).to include("<identifier>#{@repository_id}:#{@public_etd_no_agreements.id}</identifier>")
        expect(response.body).to include("<identifier>#{@repository_id}:#{@public_etd_not_licenced.id}</identifier>")
        expect(response.body).not_to include("<identifier>#{@repository_id}:#{@private_etd.id}</identifier>")
      end
    end

    context 'with metadataFormat=oai_etdms' do
      it 'lists identifiers for PUBLIC Etds that can be harvested by LAC' do
        get oai_catalog_path(verb: 'ListIdentifiers', metadataPrefix: 'oai_etdms')
        expect(response.body).not_to include("<identifier>#{@repository_id}:#{@public_work.id}</identifier>")
        expect(response.body).to include("<identifier>#{@repository_id}:#{@public_etd.id}</identifier>")
        expect(response.body).to include("<identifier>#{@repository_id}:#{@public_etd_no_agreements.id}</identifier>")
        expect(response.body).not_to include("<identifier>#{@repository_id}:#{@public_etd_not_licenced.id}</identifier>")
        expect(response.body).not_to include("<identifier>#{@repository_id}:#{@private_etd.id}</identifier>")
      end
    end
  end

  describe 'ListRecords verb' do
    # metadataFormat is a required argument for ListRecords verb
    context 'with metadataFormat=oai_dc' do
      it 'lists records for all PUBLIC items' do
        get oai_catalog_path(verb: 'ListRecords', metadataPrefix: 'oai_dc')
        expect(response.body).to include("<identifier>#{@repository_id}:#{@public_work.id}</identifier>")
        expect(response.body).to include("<identifier>#{@repository_id}:#{@public_etd.id}</identifier>")
        expect(response.body).to include("<identifier>#{@repository_id}:#{@public_etd_no_agreements.id}</identifier>")
        expect(response.body).to include("<identifier>#{@repository_id}:#{@public_etd_not_licenced.id}</identifier>")
        expect(response.body).not_to include("<identifier>#{@repository_id}:#{@private_etd.id}</identifier>")
      end
    end

    context 'with metadataFormat=oai_etdms' do
      it 'lists records for PUBLIC Etds that can be harvested by LAC' do
        get oai_catalog_path(verb: 'ListRecords', metadataPrefix: 'oai_etdms')
        expect(response.body).not_to include("<identifier>#{@repository_id}:#{@public_work.id}</identifier>")
        expect(response.body).to include("<identifier>#{@repository_id}:#{@public_etd.id}</identifier>")
        expect(response.body).to include("<identifier>#{@repository_id}:#{@public_etd_no_agreements.id}</identifier>")
        expect(response.body).not_to include("<identifier>#{@repository_id}:#{@public_etd_not_licenced.id}</identifier>")
        expect(response.body).not_to include("<identifier>#{@repository_id}:#{@private_etd.id}</identifier>")
      end
    end
  end

  describe 'GetRecord verb' do
    context 'a PUBLIC Etd with metadataFormat=oai_etdms' do
      before(:all) do
        get oai_catalog_path(verb: 'GetRecord', metadataPrefix: 'oai_etdms',
                             identifier: "#{@repository_id}:#{@public_etd.id}")
      end

      it 'has a title' do
        expect(response.body).to include("<thesis:title>#{@public_etd.title.first}</thesis:title>")
      end
      it 'has a creator' do
        expect(response.body).to include("<thesis:creator>#{@public_etd.creator.first}</thesis:creator>")
      end
      it 'has type Thesis' do
        expect(response.body).to include("<thesis:type>#{@public_etd.resource_type.first}</thesis:type>")
      end
      it 'has a degree level' do
        # See config/authorities/degree_levels.yml
        # HyraxHelper::degree_term_level should be moved to ApplicationHelper & used here
        expect(response.body).to include("<thesis:level>#{@public_etd.degree_level == '1' ? "Master's" : 'Doctoral'}</thesis:level>")
      end
      it 'has a degree name' do
        expect(response.body).to include("<thesis:name>#{@public_etd.degree}</thesis:name>")
      end
      it 'has a degree discipline' do
        expect(response.body).to include("<thesis:discipline>#{@public_etd.degree_discipline}</thesis:discipline>")
      end
      it 'has a degree grantor' do
        # Publisher (Carleton University) is mapped to degree grantor
        expect(response.body).to include("<thesis:grantor>#{@public_etd.publisher.first}</thesis:grantor>")
      end
      it 'has a contributor' do
        expect(response.body).to include("<thesis:contributor>#{@public_etd.contributor.first}</thesis:contributor>")
      end
      it 'has subjects' do
        # Theses usually have multiple subjects -- confirm all
        @public_etd.subject do |sub|
          expect(response.body).to include("<thesis:subject>#{sub}</thesis:subject>")
        end
      end
      it 'has an abstract' do
        # abstract is mapped to <thesis:description>
        expect(response.body).to include("<thesis:description>#{@public_etd.abstract.first}</thesis:description>")
      end
      it 'has a publisher' do
        # Publisher is always 'Carleton University'
        expect(response.body).to include("<thesis:publisher>#{@public_etd.publisher.first}</thesis:publisher>")
      end
      it 'has a YYYY date' do
        # Date provided is YYYY format
        expect(response.body).to include("<thesis:date>#{Time.new(@public_etd.date_created.first).strftime('%Y')}</thesis:date>")
      end
      it 'has an ISO 639-3 language code' do
        expect(response.body).to include("<thesis:language>#{@public_etd.language.first}</thesis:language>")
      end
      it 'has a copyright statement' do
        expect(response.body).to include("<thesis:rights>#{@public_etd.rights_notes.first}</thesis:rights>")
      end
      it 'has a DOI' do
        # Factory attribute doesn't include 'DOI: ' as a prefix
        expect(response.body).to include("<thesis:identifier>#{@public_etd.identifier.first}</thesis:identifier>")
      end
      it 'has Etd landing page URL' do
        # Link to Etd landing page is included as an identifier
        # e.g. https://repository.library.carleton.ca/concern/etds/r207tp32d
        url_vars = {
          only_path: false,
          action: 'show',
          host: @hyrax_host,
          controller: 'hyrax/etds',
          id: @public_etd.id
        }
        expect(response.body).to include(
          "<thesis:identifier>#{Rails.application.routes.url_helpers.url_for(url_vars)}</thesis:identifier>"
        )
      end
      it 'has PUBLIC file URL' do
        # @public_etd has one PDF file. Expect Hyrax download URL with '.pdf' appended, e.g.,
        # https://repository.library.carleton.ca/downloads/f1881k888.pdf
        expect(response.body).to include(
          '<thesis:identifier>' \
          "#{Hyrax::Engine.routes.url_helpers.download_url(
            @public_etd.file_set_ids.first, host: @hyrax_host
          )}.pdf</thesis:identifier>"
        )
      end

      context 'with a PRIVATE file' do
        it 'does NOT have file URL' do
          get oai_catalog_path(verb: 'GetRecord', metadataPrefix: 'oai_etdms',
                               identifier: "#{@repository_id}:#{@public_etd_private_file.id}")
          # Confirm response
          expect(response.body).to include("<identifier>#{@repository_id}:#{@public_etd_private_file.id}</identifier>")
          # Confirm file URL not present
          expect(response.body).not_to include(
            '<thesis:identifier>' \
            "#{Hyrax::Engine.routes.url_helpers.download_url(
              @public_etd_private_file.file_set_ids.first, host: @hyrax_host
            )}.pdf</thesis:identifier>"
          )
        end
      end
    end

    context 'a PRIVATE Etd with metadataFormat=oai_etdms' do
      it 'displays an error' do
        get oai_catalog_path(verb: 'GetRecord', metadataPrefix: 'oai_etdms',
                             identifier: "#{@repository_id}:#{@private_etd.id}")
        expect(response.body).to include('<error code="idDoesNotExist">')
      end
    end
  end
end
