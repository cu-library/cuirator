require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'View an Research Work', js: true do
  let(:research_works) { FactoryBot.create(:public_research_work_with_private_file) }

  context 'as an admin user' do
    # admin user seeded in db
    let(:admin_user) { User.find_by(email: 'admin_user@example.com') }

    before { login_as admin_user }

    scenario 'limited-access fields displayed on show page' do
      visit '/concern/research_works/' + research_works.id
      expect(page).to have_content 'Internal Note'
    end

    scenario 'limited-access fields included in Research JSON' do
      visit '/concern/research_works/' + research_works.id + '.json'
      expect(JSON.parse(page.text).keys.include?('internal_note')).to be true
    end
  end

  context 'as a Library staff user' do
    # staff user seeded in db
    let(:staff_user) { User.find_by(email: 'staff_user@example.com') }

    before { login_as staff_user }

    scenario 'limited-access fields displayed on show page' do
      visit '/concern/research_works/' + research_works.id
      expect(page).to have_content 'Internal Note'
    end

    scenario 'limited-access fields included in Research Work JSON' do
      visit '/concern/research_works/' + research_works.id + '.json'
      expect(JSON.parse(page.text).keys.include?('internal_note')).to be true
    end

  end

  context 'as a logged-out user' do
    scenario 'limited-access fields NOT displayed on show page' do
      visit '/concern/research_works/' + research_works.id
      expect(page).not_to have_content 'Internal Note'
    end

    scenario 'limited-access fields NOT included in Research JSON' do
      visit '/concern/research_works/' + research_works.id + '.json'
      expect(JSON.parse(page.text).keys.include?('internal_note')).to be false
    end

  end

end