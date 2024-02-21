require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Create an Etd', js: true do

  # Required metadata
  let(:work_title) { 'Create a thesis / dissertation ' + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
  let(:creator) { 'Surname, Given Name' }
  let(:resource_type) { 'Thesis' }
  let(:degree_level) { "Master's" }
  let(:degree_name) { 'Master of Science (M.Sc.)' }
  let(:degree_discipline) { 'Engineering' }

  # Optional metadata. Not required to create & save an Etd, although
  # most are typically provided in the automated transfer & deposit
  let(:abstract) { 'An abstract is a brief summary of the work.' }
  let(:rights_notes) { 'Copyright © 2023 the author(s).' }
  let(:publisher) { 'Carleton University' }
  let(:date_created) { '2023-09-30' }
  let(:subjects) { ['Electric networks', 'System theory', 'System analysis'] }
  let(:language) { 'English' }
  let(:identifier) { 'DOI: https://doi.org/10.22215/1234' }

  # internal metadata: visible to repository managers only
  let(:internal_note) { 'This is an internal note added by the Metadata team.' }
  let(:agreements) do
    [
      'Academic Integrity Statement',
      'FIPPA Statement',
      'Carleton University Thesis Licence Agreement',
      'Library and Archives Canada Non-Exclusive Licence'
    ]
  end

  # Context for Library staff user only - create_work_spec.rb confirms
  # deposit by admin user and no access to deposit works by basic user
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

      # Visit page to create a new Etd
      click_link 'Works'
      expect(page).to have_content 'Add New Work'

      # Choose Etd Work type
      click_on 'Add New Work'
      choose 'payload_concern', option: 'Etd'
      click_button 'Create work'
      expect(page).to have_content 'Add New Etd'

      # Switch to Files tab
      click_link 'Files'
      expect(page).to have_content 'Add files'

      # Upload file(s)
      within('div#add-files') do
        attach_file('files[]', File.join(fixture_path, 'etd.pdf'), visible: false)
      end

      # Add required metadata
      click_link 'Descriptions'
      fill_in('Title', with: work_title)
      fill_in('Creator', with: creator)
      select(resource_type, from: 'Resource type')
      select(degree_level, from: 'Thesis Degree Level')
      fill_in('Thesis Degree Name', with: degree_name)
      fill_in('Thesis Degree Discipline', with: degree_discipline)

      # With Selenium / Chromedriver, focus remains on the select box. Click
      # body to move focus outside select box so next element can be found.
      find('body').click

      # Add optional metadata
      click_on 'Additional fields'
      fill_in('Abstract', with: abstract)
      fill_in('Rights notes', with: rights_notes)
      fill_in('Publisher', with: publisher)
      fill_in('Date Created', with: date_created)
      select language, from: 'Language'
      fill_in('Identifier', with: identifier)

      # Set first subject, then click 'Add another' for each additional entry
      subjects.each do |subject|
        page.all('input.etd_subject').last.set(subject)
        click_on('Add another Subject') unless subject == subjects.last
      end

      # Add internal (staff only) metadata
      fill_in('Internal Note(s) (Admin only)', with: internal_note)

      # Agreements: select first agreement, then click 'Add another' for each additional entry
      agreements.each do |agreement|
        page.all('select.etd_agreement').last.select(agreement)
        click_on('Add another Agreement(s) (Admin only)') unless agreement == agreement.last
      end

      # Set work visibility
      choose('etd_visibility_open')

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
      expect(page).to have_content degree_level
      expect(page).to have_content degree_name
      expect(page).to have_content degree_discipline

      # Optional metadata
      expect(page).to have_content abstract
      expect(page).to have_content rights_notes
      expect(page).to have_content publisher
      expect(page).to have_content language
      expect(page).to have_content identifier
      subjects.each { |subject| expect(page).to have_content subject }

      # Confirm date_created format is YYYY
      expect(page).to have_content date_created.to_date.strftime("%Y")

      # Internal metadata: visible to repository managers only
      expect(page).to have_content internal_note
      agreements.each { |agreement| expect(page).to have_content agreement }

      # Log out user
      visit '/users/sign_out'
      expect(page).to have_content "Signed out successfully"
    end
  end
end
