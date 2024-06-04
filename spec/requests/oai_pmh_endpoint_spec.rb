# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OAI-PMH endpoint' do
  let(:repository_name) { 'Carleton University Institutional Repository' }
  let(:repository_url) { CatalogController.blacklight_config.oai[:provider][:repository_url] }
  let(:repository_id) { 'oai:repository.library.carleton.ca' }

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
      expect(response.body).to include repository_name
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
    context 'for a Work' do
      let(:work_attributes) do
        {
          title: ["Example work in OAI-DC record#{Time.new.strftime('%Y-%m-%d %H:%M:%S')}"],
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
        }
      end
      let(:work) { FactoryBot.create(:work, :public, work_attributes) }

      before do
        get oai_catalog_path(verb: 'GetRecord', metadataPrefix: 'oai_dc', identifier: "#{repository_id}:#{work.id}")
      end

      it 'includes work URL in dc:identifier' do
        expect(response.body).to include("<dc:identifier>#{repository_url.gsub('/catalog/oai', "/concern/works/#{work.id}")}</dc:identifier>")
      end

      it 'includes Date Created in dc:date with YYYY-MM-DD format' do
        expect(response.body).to include("<dc:date>#{work.date_created.first}</dc:date>")
      end

      it 'includes Title in dc:title' do
        expect(response.body).to include("<dc:title>#{work.title.first}</dc:title>")
      end

      it 'includes Creator in dc:creator' do
        expect(response.body).to include("<dc:creator>#{work.creator.first}</dc:creator>")
      end

      it 'includes Contributor in dc:contributor' do
        expect(response.body).to include("<dc:contributor>#{work.contributor.first}</dc:contributor>")
      end

      it 'includes Rights Statement, Rights Notes, and Creative Commons license in dc:rights' do
        expect(response.body).to include("<dc:rights>#{work.rights_statement.first}</dc:rights>")
        expect(response.body).to include("<dc:rights>#{work.rights_notes.first}</dc:rights>")
        expect(response.body).to include("<dc:rights>#{work.license.first}</dc:rights>")
      end

      it 'includes Publisher in dc:publisher' do
        expect(response.body).to include("<dc:publisher>#{work.publisher.first}</dc:publisher>")
      end

      it 'includes Identifier in dc:identifier' do
        expect(response.body).to include("<dc:identifier>#{work.identifier.first}</dc:identifier>")
      end

      it 'includes Language in dc:language' do
        expect(response.body).to include("<dc:language>#{work.language.first}</dc:language>")
      end

      it 'includes Resource Type in dc:type' do
        expect(response.body).to include("<dc:type>#{work.resource_type.first}</dc:type>")
      end

      it 'includes Keyword and Subject in dc:subject' do
        work.keyword.each { |keyword| expect(response.body).to include("<dc:subject>#{keyword}</dc:subject>")}
        work.subject.each { |subject| expect(response.body).to include("<dc:subject>#{subject}</dc:subject>")}
      end

      it 'includes Abstract and Description in dc:description' do
        expect(response.body).to include("<dc:description>#{work.abstract.first}</dc:description>")
        expect(response.body).to include("<dc:description>#{work.description.first}</dc:description>")
      end

      it 'includes Related URL in dc:relation' do
        expect(response.body).to include("<dc:relation>#{work.related_url.first}</dc:relation>")
      end
    end

    context 'for an Etd' do
      let(:etd_attributes) do
        {
          title: ["Example Etd in OAI-DC record#{Time.new.strftime('%Y-%m-%d %H:%M:%S')}"],
          creator: ['Lastname, Given'],
          contributor: ['Surname, First (Supervisor)'],
          date_created: ['2023-04-02'],
          rights_notes: ['Copyright 2023'],
          publisher: ['Carleton University'],
          identifier: ['DOI: https://doi.org/10.22215/2023-12345'],
          language: ['eng'],
          resource_type: ['Thesis'],
          subject: ['Subject Area', 'Subject Area -- Ontario', 'Subject Area -- 20th century'],
          abstract: ['A summary of the work.']
        }
      end
      let(:etd) { FactoryBot.create(:etd, :public, etd_attributes) }

      before do
        get oai_catalog_path(verb: 'GetRecord', metadataPrefix: 'oai_dc', identifier: "#{repository_id}:#{etd.id}")
      end

      it 'includes Etd URL in dc:identifier' do
        expect(response.body).to include("<dc:identifier>#{repository_url.gsub('/catalog/oai', "/concern/etds/#{etd.id}")}</dc:identifier>")
      end

      it 'includes Date Created in dc:date with YYYY format' do
        expect(response.body).to include("<dc:date>#{Date.parse(etd.date_created.first).year.to_s}</dc:date>")
      end

      it 'includes Title in dc:title' do
        expect(response.body).to include("<dc:title>#{etd.title.first}</dc:title>")
      end

      it 'includes Creator in dc:creator' do
        expect(response.body).to include("<dc:creator>#{etd.creator.first}</dc:creator>")
      end

      it 'includes Contributor in dc:contributor' do
        expect(response.body).to include("<dc:contributor>#{etd.contributor.first}</dc:contributor>")
      end

      it 'includes Rights Notes in dc:rights' do
        expect(response.body).to include("<dc:rights>#{etd.rights_notes.first}</dc:rights>")
      end

      it 'includes Publisher in dc:publisher' do
        expect(response.body).to include("<dc:publisher>#{etd.publisher.first}</dc:publisher>")
      end

      it 'includes Identifier in dc:identifier' do
        expect(response.body).to include("<dc:identifier>#{etd.identifier.first}</dc:identifier>")
      end

      it 'includes Language in dc:language' do
        expect(response.body).to include("<dc:language>#{etd.language.first}</dc:language>")
      end

      it 'includes Resource Type in dc:type' do
        expect(response.body).to include("<dc:type>#{etd.resource_type.first}</dc:type>")
      end

      it 'includes Subject in dc:subject' do
        etd.subject.each { |subject| expect(response.body).to include("<dc:subject>#{subject}</dc:subject>")}
      end

      it 'includes Abstract in dc:description' do
        expect(response.body).to include("<dc:description>#{etd.abstract.first}</dc:description>")
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
      expect(CatalogController.blacklight_config.oai[:document][:set_fields][0][:solr_field]).to eq('member_of_collections_ssim')
    end
  end
end
