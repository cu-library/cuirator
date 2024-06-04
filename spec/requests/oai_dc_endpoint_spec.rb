# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OAI-DC endpoint' do
  # Set up config and create works
  before(:all) do
    @repository_name = 'Carleton University Institutional Repository'
    @hyrax_host = CatalogController.blacklight_config.oai[:provider][:repository_url].sub('/catalog/oai', '')
    @repository_id = 'oai:repository.library.carleton.ca'

    # Create a public work with extra attributes
    @public_work =
      FactoryBot.create(:public_work_with_public_file, {
                          title: ["Public work #{Time.new.strftime('%Y-%m-%d %H:%M:%S')}"],
                          creator: ['Lastname, Given'],
                          contributor: ['Surname, First'],
                          date_created: ['2023-04-02'],
                          rights_statement: ['http://rightsstatements.org/vocab/InC/1.0/'],
                          rights_notes: ['Copyright 2023'],
                          license: ['https://creativecommons.org/licenses/by/4.0/'],
                          publisher: ['Large Publishing Co., Ltd.'],
                          identifier: ['DOI: https://doi.org/10.22215/2023-12345'],
                          language: ['eng'],
                          resource_type: ['Article'],
                          keyword: ['Term', 'Descriptive phrase', 'Key topic'],
                          subject: ['Subject Area', 'Subject Area -- Ontario', 'Subject Area -- 20th century'],
                          abstract: ['A summary of the work.'],
                          description: ['A description of the work.'],
                          related_url: ['https://www.example.com/related/work']
                        })

    # Public work with private file: file URL should not be included in oai_dc
    @public_work_private_file =
      FactoryBot.create(:public_work_with_private_file, {
                          title: ["Public Work with private file #{Time.new.strftime('%Y-%m-%d %H:%M:%S')}"]
                        })

    # Create a private work with default attributes
    @private_work =
      FactoryBot.create(:work, :private, {
                          title: ["Private work #{Time.new.strftime('%Y-%m-%d %H:%M:%S')}"]
                        })

    # Create a public Etd with default attributes
    @public_etd =
      FactoryBot.create(:etd, :public, { title: ["Public Etd #{Time.new.strftime('%Y-%m-%d %H:%M:%S')}"] })
  end

  # the endpoint is available
  describe 'root page' do
    it 'displays an error message about missing verb' do
      get oai_catalog_path
      expect(response.body).to include 'not a legal OAI-PMH verb'
    end
  end

  # the Identify verb returns repository information
  describe 'Identify verb' do
    it 'displays repository information' do
      get oai_catalog_path(verb: 'Identify')
      expect(response.body).to include @repository_name
    end
  end

  # the endpoint supports OAI-DC as a metadata format
  describe 'ListMetadataFormats verb' do
    it 'lists oai_dc as a supported format' do
      get oai_catalog_path(verb: 'ListMetadataFormats')
      expect(response.body).to include('<metadataPrefix>oai_dc</metadataPrefix>')
    end
  end

  describe 'GetRecord verb' do
    context 'a PUBLIC Work with metadataFormat=oai_dc' do
      before(:all) do
        get oai_catalog_path(verb: 'GetRecord', metadataPrefix: 'oai_dc',
                             identifier: "#{@repository_id}:#{@public_work.id}")
      end
      it 'includes Work URL in dc:identifier' do
        expect(response.body).to include("<dc:identifier>#{@hyrax_host}/concern/works/#{@public_work.id}</dc:identifier>")
      end
      it 'includes Date Created in dc:date with YYYY-MM-DD format' do
        expect(response.body).to include("<dc:date>#{@public_work.date_created.first}</dc:date>")
      end
      it 'includes Title in dc:title' do
        expect(response.body).to include("<dc:title>#{@public_work.title.first}</dc:title>")
      end
      it 'includes Creator in dc:creator' do
        expect(response.body).to include("<dc:creator>#{@public_work.creator.first}</dc:creator>")
      end
      it 'includes Contributor in dc:contributor' do
        expect(response.body).to include("<dc:contributor>#{@public_work.contributor.first}</dc:contributor>")
      end
      it 'includes Rights Statement, Rights Notes, and Creative Commons license in dc:rights' do
        expect(response.body).to include("<dc:rights>#{@public_work.rights_statement.first}</dc:rights>")
        expect(response.body).to include("<dc:rights>#{@public_work.rights_notes.first}</dc:rights>")
        expect(response.body).to include("<dc:rights>#{@public_work.license.first}</dc:rights>")
      end
      it 'includes Publisher in dc:publisher' do
        expect(response.body).to include("<dc:publisher>#{@public_work.publisher.first}</dc:publisher>")
      end
      it 'includes Identifier in dc:identifier' do
        expect(response.body).to include("<dc:identifier>#{@public_work.identifier.first}</dc:identifier>")
      end
      it 'includes Language in dc:language' do
        expect(response.body).to include("<dc:language>#{@public_work.language.first}</dc:language>")
      end
      it 'includes Resource Type in dc:type' do
        expect(response.body).to include("<dc:type>#{@public_work.resource_type.first}</dc:type>")
      end
      it 'includes Keyword and Subject in dc:subject' do
        @public_work.keyword.each { |keyword| expect(response.body).to include("<dc:subject>#{keyword}</dc:subject>")}
        @public_work.subject.each { |subject| expect(response.body).to include("<dc:subject>#{subject}</dc:subject>")}
      end
      it 'includes Abstract and Description in dc:description' do
        expect(response.body).to include("<dc:description>#{@public_work.abstract.first}</dc:description>")
        expect(response.body).to include("<dc:description>#{@public_work.description.first}</dc:description>")
      end
      it 'includes Related URL in dc:relation' do
        expect(response.body).to include("<dc:relation>#{@public_work.related_url.first}</dc:relation>")
      end

      context 'with a PRIVATE file' do
        it 'does NOT have file URL in dc:identifier' do
          get oai_catalog_path(verb: 'GetRecord', metadataPrefix: 'oai_dc',
                               identifier: "#{@repository_id}:#{@public_work_private_file.id}")
          # Confirm response
          expect(response.body).to include("<identifier>#{@repository_id}:#{@public_work_private_file.id}</identifier>")
          # Confirm file URL not present
          # e.g., https://repository.library.carleton.ca/downloads/f1881k888.pdf
          expect(response.body).not_to include(
            '<dc:identifier>' \
            "#{@hyrax_host}/downloads/#{@public_work_private_file.file_set_ids.first}.pdf</dc:identifier>"
          )
        end
      end
    end

    context 'a PUBLIC Etd with metadataFormat=oai_dc' do
      before(:all) do
        get oai_catalog_path(verb: 'GetRecord', metadataPrefix: 'oai_dc',
                             identifier: "#{@repository_id}:#{@public_etd.id}")
      end
      it 'includes Etd URL in dc:identifier' do
        expect(response.body).to include(
          "<dc:identifier>#{@hyrax_host}/concern/etds/#{@public_etd.id}</dc:identifier>"
        )
      end
      it 'includes Date Created in dc:date with YYYY format' do
        expect(response.body).to include("<dc:date>#{Date.parse(@public_etd.date_created.first).year}</dc:date>")
      end
      it 'includes Title in dc:title' do
        expect(response.body).to include("<dc:title>#{@public_etd.title.first}</dc:title>")
      end
      it 'includes Creator in dc:creator' do
        expect(response.body).to include("<dc:creator>#{@public_etd.creator.first}</dc:creator>")
      end
      it 'includes Contributor in dc:contributor' do
        expect(response.body).to include("<dc:contributor>#{@public_etd.contributor.first}</dc:contributor>")
      end
      it 'includes Rights Notes in dc:rights' do
        expect(response.body).to include("<dc:rights>#{@public_etd.rights_notes.first}</dc:rights>")
      end
      it 'includes Publisher in dc:publisher' do
        expect(response.body).to include("<dc:publisher>#{@public_etd.publisher.first}</dc:publisher>")
      end
      it 'includes Identifier in dc:identifier' do
        expect(response.body).to include("<dc:identifier>#{@public_etd.identifier.first}</dc:identifier>")
      end
      it 'includes Language in dc:language' do
        expect(response.body).to include("<dc:language>#{@public_etd.language.first}</dc:language>")
      end
      it 'includes Resource Type in dc:type' do
        expect(response.body).to include("<dc:type>#{@public_etd.resource_type.first}</dc:type>")
      end
      it 'includes Subject in dc:subject' do
        @public_etd.subject.each { |subject| expect(response.body).to include("<dc:subject>#{subject}</dc:subject>") }
      end
      it 'includes Abstract in dc:description' do
        expect(response.body).to include("<dc:description>#{@public_etd.abstract.first}</dc:description>")
      end
    end

    context 'a PRIVATE Work with metadataFormat=oai_dc' do
      it 'displays an error' do
        get oai_catalog_path(verb: 'GetRecord', metadataPrefix: 'oai_dc',
                             identifier: "#{@repository_id}:#{@private_work.id}")
        expect(response.body).to include('<error code="idDoesNotExist">')
      end
    end
  end

  # describe 'ListSets verb' do
  #   it 'displays Collections as sets'
  #   ... etc
  # Factory / factories to create collection type, collection & add works to confirm OAI ListSets config, etc.,
  # is a lot of overhead that would duplicate efforts in Hyrax. See https://github.com/samvera/hyrax/pull/6664
  # and e.g. spec/factories/collections.rb. Being able to use upstream factories will be great when we upgrade
  # to Hyrax v5! For now, fetch OAI config & confirm Sets are configured based on collection membership.
  describe 'ListSets verb' do
    it 'is configured to show Collections as Sets' do
      expect(CatalogController.blacklight_config.oai[:document][:set_fields].count).to eq(1)
      expect(CatalogController.blacklight_config.oai[:document][:set_fields][0][:label]).to eq('Collection')
      expect(CatalogController.blacklight_config.oai[:document][:set_fields][0][:solr_field]).to eq('member_of_oai_sets_ssim')
    end
  end
end
