require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Create a work', js: true do

  # Rquired metadata
  let(:work_title) { "Create a generic work " + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
  let(:resource_type) { "Report" }

  # Optional metadata
  let(:creator) { "Surname, Given Name" }
  let(:date_created) { "2023-11-30" }
  let(:abstract) { "An abstract is a brief summary of the work." }
  let(:language) { "English" }
  let(:identifier) { "DOI: https://doi.org/10.22215/1234" }
  let(:citation) { "Surname, G. (2023). #{work_title}. Publishing Co., Ltd. https://doi.org/10.22215/1234" }
  let(:alternative_title) {'A title that is alternate to the original'}
  let(:internal_note) { 'This is an internal note added by the Metadata team.' }

  context 'as an admin user' do
    # admin user seeded in db
    let(:admin_user) { User.find_by(email: 'admin_user@example.com') }
    before { login_as admin_user }
    include_examples 'Create and save work'
  end

  context 'as a Library staff user' do
    # staff user seeded in db
    let(:staff_user) { User.find_by(email: 'staff_user@example.com') }
    before { login_as staff_user }
    include_examples 'Create and save work'
  end

  context 'not permitted as a basic user' do
    let(:basic_user) { User.find_by(email: 'basic_user@example.com') }
    before { login_as basic_user }

    scenario do
      # Navigate to the Dashboard
      visit '/dashboard'
      expect(page).to have_content "Dashboard"

      # Confirm logged-in user doesn't have option to create a new work
      click_link "Works"
      expect(page).not_to have_content "Add New Work"
      
      # Log out user
      visit '/users/sign_out'
      expect(page).to have_content "Signed out successfully"
    end
  end

end