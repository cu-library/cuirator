require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'View a work', js: true do
  let(:work) { FactoryBot.create(:public_work_with_private_file) }

  context 'when not logged in' do
    scenario 'private file is NOT displayed' do
      # View work
      visit '/concern/works/' + work.id
      expect(page).not_to have_css('table.related-files')
      expect(page).to have_content 'There are no publicly available items in this Work.'
    end
  end

  context 'as a logged-in user' do
    # basic user (login only, no privileges) seeded in db
    let(:basic_user) { User.find_by(email: 'basic_user@example.com') }

    before { login_as basic_user }

    scenario 'private file is NOT displayed' do
      # View work
      visit '/concern/works/' + work.id
      expect(page).not_to have_css('table.related-files')
      expect(page).to have_content 'There are no publicly available items in this Work.'
    end
  end

  context 'as a Library staff user' do
    # staff user seeded in db
    let(:staff_user) { User.find_by(email: 'staff_user@example.com') }

    before { login_as staff_user }

    scenario 'private file is displayed' do
      # View work
      visit '/concern/works/' + work.id
      expect(page).to have_css('table.related-files')
    end
  end



end