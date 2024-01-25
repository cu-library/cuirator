require 'rails_helper'

RSpec.feature 'Browse the catalog', js: true do
  let(:etd) { FactoryBot.create(:public_etd) }

  # Bulkrax requires a source identifier
  let(:bulkrax_etd) { FactoryBot.create(:public_etd, source: ['abcd-efgh-ijkl-mnop']) } 

  context 'when not logged in' do
    scenario 'limited-access Etd fields are NOT included in RDF' do
      # Filter catalog by Etd identifer
      visit '/catalog.jsonld?f[id][]=' + etd.id

      # parse as JSON
      etd_jsonld = JSON.parse(page.text)
      expect(etd_jsonld.keys.include?('bibo:Note')).to be false
      expect(etd_jsonld.keys.include?('schema:license')).to be false
    end

    scenario 'catalog JSON can be queried by Bulkrax source identifier' do
      visit '/catalog.json?f[source_tesim][]=' + bulkrax_etd.source.first

      # Expect Etd id to be present in JSON
      etd_json = JSON.parse(page.text)['data'].first
      expect(etd_json.keys.include?('id')).to be true
      expect(etd_json['id']).to eq bulkrax_etd.id
    end
  end



end
