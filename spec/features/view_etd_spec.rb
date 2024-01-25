require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'View an Etd', js: true do
  let(:etd) { FactoryBot.create(:public_etd) }

  context 'as an admin user' do
    # admin user seeded in db
    let(:admin_user) { User.find_by(email: 'admin_user@example.com') }

    before { login_as admin_user }

    scenario 'limited-access fields displayed on show page' do
      visit '/concern/etds/' + etd.id
      expect(page).to have_content 'Internal Note(s) (Admin only)'
      expect(page).to have_content 'Agreement(s) (Admin only)'
    end

    scenario 'limited-access fields included in Etd JSON' do
      visit '/concern/etds/' + etd.id + '.json'
      expect(JSON.parse(page.text).keys.include?('agreement')).to be true
      expect(JSON.parse(page.text).keys.include?('internal_note')).to be true
    end

    scenario 'limited-access fields included in Etd RDF' do
      visit '/concern/etds/' + etd.id + '.jsonld'
      expect(JSON.parse(page.text).keys.include?('bibo:Note')).to be true      # predicate for internal_note
      expect(JSON.parse(page.text).keys.include?('schema:license')).to be true # predicate for agreement
    end
  end

  context 'as a Library staff user' do
    # staff user seeded in db
    let(:staff_user) { User.find_by(email: 'staff_user@example.com') }

    before { login_as staff_user }

    scenario 'limited-access fields displayed on show page' do
      visit '/concern/etds/' + etd.id
      expect(page).to have_content 'Internal Note(s) (Admin only)'
      expect(page).to have_content 'Agreement(s) (Admin only)'
    end

    scenario 'limited-access fields included in Etd JSON' do
      visit '/concern/etds/' + etd.id + '.json'
      expect(JSON.parse(page.text).keys.include?('agreement')).to be true
      expect(JSON.parse(page.text).keys.include?('internal_note')).to be true
    end

    scenario 'limited-access fields included in Etd RDF' do
      visit '/concern/etds/' + etd.id + '.jsonld'
      expect(JSON.parse(page.text).keys.include?('bibo:Note')).to be true      # predicate for internal_note
      expect(JSON.parse(page.text).keys.include?('schema:license')).to be true # predicate for agreement
    end
  end

  context 'as a logged-out user' do
    scenario 'limited-access fields NOT displayed on show page' do
      visit '/concern/etds/' + etd.id
      expect(page).not_to have_content 'Internal Note(s) (Admin only)'
      expect(page).not_to have_content 'Agreement(s) (Admin only)'
    end

    scenario 'limited-access fields NOT included in Etd JSON' do
      visit '/concern/etds/' + etd.id + '.json'
      expect(JSON.parse(page.text).keys.include?('agreement')).to be false
      expect(JSON.parse(page.text).keys.include?('internal_note')).to be false
    end

    scenario 'limited-access fields NOT included in Etd RDF' do
      visit '/concern/etds/' + etd.id + '.jsonld'
      expect(JSON.parse(page.text).keys.include?('bibo:Note')).to be false
      expect(JSON.parse(page.text).keys.include?('schema:license')).to be false
    end
  end

end