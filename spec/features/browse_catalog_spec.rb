require 'rails_helper'

RSpec.feature 'Browse the catalog', js: true do

  context 'when not logged in' do

    scenario 'limited-access Etd fields are not included in RDF' do
      FactoryBot.create(:public_etd)

      # Browse Etds
      visit '/catalog.jsonld?f[human_readable_type_sim][]=Etd'

      # JSON-LD may not parse correctly. Check page content agreement, internal_note predicates
      expect(page).not_to have_content 'bibo:Note'
      expect(page).not_to have_content 'schema:license'
    end
  end

end
