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
  let(:internal_note) { 'This is an internal note added by the Metadata team' }

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

    scenario do
      # Navigate to the Dashboard
      visit '/dashboard'
      expect(page).to have_content 'Dashboard'

      # Clear the cookie notice -- otherwise, sometimes blocks Save click
      click_button 'Ok. Got it.' if page.find('div.cookies-eu') 
      expect(page).not_to have_content 'This site uses cookies'

      # Visit page to create a new research work
      click_link 'Works'
      expect(page).to have_content 'Add New Work'

      # Choose Research Work type
      click_on 'Add New Work'
      choose 'payload_concern', option: 'Work'
      click_button 'Create work'
      expect(page).to have_content 'Add New Work'

      # Switch to Files tab
      click_link 'Files'
      expect(page).to have_content 'Add files'

      # Upload file(s) 
      within('div#add-files') do
        attach_file('files[]', File.join(fixture_path, 'research_work.pdf'), visible: false)
      end

      # Add required metadata
      click_link 'Descriptions'
      fill_in('Title', with: work_title)
      
      select(resource_type, from: 'Resource type')

      # With Selenium / Chromedriver, focus remains on the select box. Click
      # body to move focus outside select box so next element can be found.
      find('body').click
    
      # Add optional metadata
      click_on 'Additional fields'
      fill_in('Alternative title', with: alternative_title)
      fill_in('Creator', with: creator)
      fill_in('Abstract', with: abstract)
      fill_in('Internal Note(s) (Admin only)', with: internal_note)

      # Set work visibility
      choose('work_visibility_open')

      # Accept deposit agreement, if configured for active acceptance
      check('agreement') if Flipflop::FeatureSet.current.enabled?(:active_deposit_agreement_acceptance)
      
      # Save work
      click_on("Save")

      # Expect work files to be processing in the background
      expect(page).to have_content "Your files are being processed"
  
      # Required metadata
      expect(page).to have_content work_title
      expect(page).to have_content creator
      expect(page).to have_content resource_type
  
      # Optional metadata
      expect(page).to have_content alternative_title
      expect(page).to have_content abstract
      expect(page).to have_content internal_note

      # Log out user
      visit '/users/sign_out'
      expect(page).to have_content "Signed out successfully"
    end
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