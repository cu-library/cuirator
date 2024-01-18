require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Create a ResearchWork', js: true do

  # Rquired metadata
  let(:work_title) { 'Create a research work ' + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
  let(:creator) { 'Surname, Given Name' }
  let(:resource_type) { 'Article' }

    # Optional metadata
  let(:abstract) { 'An abstract is a brief summary of the work.' }
  let(:keywords) { ['Keyword', 'Descriptive phrase', 'Research area'] }
  let(:license) { 'Creative Commons BY Attribution 4.0 International' }
  let(:rights_notes) { 'Copyright © 2023 the author(s)' }
  let(:publisher) { 'Research Journal Publisher' }
  let(:date_created) { '2023-11-30' }
  let(:language) { 'English' }
  let(:identifier) { 'DOI: https://doi.org/10.22215/1234' }
  let(:citation) { "Surname, G. (2023). #{work_title}. #{publisher}. https://doi.org/10.22215/1234" }

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

      # Visit page to create a new research work
      click_link 'Works'
      expect(page).to have_content 'Add New Work'

      # Choose Research Work type
      click_on 'Add New Work'
      choose 'payload_concern', option: 'ResearchWork'
      click_button 'Create work'
      expect(page).to have_content 'Add New Research Work'

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
      fill_in('Creator', with: creator)
      select(resource_type, from: 'Resource type')

      # With Selenium / Chromedriver, focus remains on the select box. Click
      # body to move focus outside select box so next element can be found.
      find('body').click
    
      # Add optional metadata
      click_on 'Additional fields'
      fill_in('Abstract', with: abstract)
    
      # Set keyword, then click 'Add another' for each additional entry
      keywords.each do |keyword|
        page.all('input.research_work_keyword').last.set(keyword)
        click_on('Add another Keyword') unless keyword == keywords.last
      end

      select license, from: 'License'
      fill_in('Rights notes', with: rights_notes)
      fill_in('Publisher', with: publisher)
      fill_in('Date Created', with: date_created)
      select language, from: 'Language'
      fill_in('Identifier', with: identifier)
      fill_in('Citation', with: citation)

      # Set work visibility
      choose('research_work_visibility_open')

      # Accept deposit agreement
      check('agreement')

      click_on("Save")

      # Expect work files to be processing in the background
      expect(page).to have_content "Your files are being processed"
  
      # Required metadata
      expect(page).to have_content work_title
      expect(page).to have_content creator
      expect(page).to have_content resource_type
  
      # Optional metadata
      expect(page).to have_content abstract
      keywords.each { |keyword| expect(page).to have_content keyword }
      expect(page).to have_content license
      expect(page).to have_content rights_notes
      expect(page).to have_content publisher
      expect(page).to have_content date_created
      expect(page).to have_content language
      expect(page).to have_content identifier 
      expect(page).to have_content citation

      # Log out user
      visit '/users/sign_out'
      expect(page).to have_content "Signed out successfully"
    end
  end
end
