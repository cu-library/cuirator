require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Import a Work with Bulkrax', js: true do

  context 'as an admin user' do
    let(:admin_user) { User.find_by(email: 'admin_user@example.com') }

    # Importer metadata
    let(:importer_name) { 'Bulkrax Etd importer ' + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
    let(:default_admin_set) { 'Default Admin Set' }
    let(:csv_parser) { 'CSV - Comma Separated Values' }
    let(:bulkrax_import_file) { File.join(fixture_path, 'bulkrax_import_etd.zip') }

    # Values defined in metadata.csv in bulkrax_import_etd.zip
    let(:source_identifier) { '0b2980de-a7a0-4bdd-83bd-7b8acc8099f3' }

    # Values defined in metadata.csv that are expected to be parsed from CSV
    let(:etd_metadata) do
      {
        # source - verified in work entries table and entry page
        model: ['Etd'],
        title: ['Title of thesis or dissertation'],
        creator: ['Lastname, First Name'],
        identifier: ['DOI: https://doi.org/10.22215/etd/2023-99999999'],
        abstract: ['Abstract of the thesis.' ],
        publisher: ['Carleton University'],
        date_created: ['2023-05-11'],
        language: ['eng'],
        degree: ['Doctor of Philosophy (Ph.D.)'],
        degree_discipline: ['Engineering, Electrical and Computer'],
        degree_level: ['2'], 
        resource_type: ['Thesis'],
        rights_notes: ['Copyright © 2023 the author(s). Theses may be used for non-commercial research, educational, or related academic purposes only.'], # etc etc
        # in multi-valued fields, individual values are wrapped in quotes after parsing
        subject: ['"System theory"', '"Electric networks"', '"System analysis"', '"Computer science"', '"Artificial intelligence"'],
        contributor: ['"Given Name Surname (Advisor)"', '"First N. Person (Co-author)"', '"Another N. Partner (Co-author)"'],
        agreement: [
          '"https://repository.library.carleton.ca/concern/works/pc289j04q"',
          '"https://repository.library.carleton.ca/concern/works/zc77sq08x"',
          '"https://repository.library.carleton.ca/concern/works/nv9352841"',
          '"https://repository.library.carleton.ca/concern/works/tt44pm84n"'
        ],
        file: ['etd.pdf', 'supplemental_files.zip'] # Can only match file name -- parsed value includes tmp path
      }
    end

    before { login_as admin_user }

    scenario 'can view importers in Dashboard' do
      visit '/dashboard'
      within '.sidebar' do
        expect(page).to have_content 'Importers'
      end

      visit '/importers'
      within '.main-header' do
        expect(page).to have_content 'Importers'
      end
    end

    scenario 'can create and run an importer' do
      visit '/importers'
      click_on 'New'
      expect(page).to have_content 'New Importer'

      # Clear the cookie notice & confirm it's no longer visible
      expect(page).to have_content 'This site uses cookies'
      click_button 'Ok. Got it.'
      expect(page).not_to have_content 'This site uses cookies'

      fill_in('Name', with: importer_name)
      select(default_admin_set, from: 'Administrative Set')
      select(csv_parser, from: 'Parser')

      # Upload zip w/ metadata.csv and files
      choose 'Upload a File'
      attach_file('importer[parser_fields][file]', bulkrax_import_file, make_visible: true)
      click_on 'Create and Import'

      # give import time to complete
      # there are better ways to do this - check sidekiq job queue
      sleep(30)

      # Returns to importer list. Confirm importer has been created.
      page.refresh
      expect(page).to have_content importer_name
      expect(page).to have_content 'Complete'

      # Click through to importer view
      page.find('a', text: importer_name).click
      expect(page).to have_content "Importer: #{importer_name}"

      # Confirm work entry has been found and imported
      work_entries = page.find('#work-entries')
      expect(work_entries).to have_content source_identifier
      expect(work_entries).to have_content 'Complete'

      # Navigate to imported work
      click_on source_identifier
      expect(page).to have_content 'Identifier: ' + source_identifier

      # Expand parsed metadata section 
      page.find('a', text: 'Parsed Metadata:').click

      # Extract parsed metadata into a hash
      parsed_metadata = {}
      page.find('#parsed-metadata-show div.accordion-body').native.attribute('innerHTML').split('<br>').each do |entry|
        values = entry.gsub(/<\/?strong>/, '').split(':', 2)
        parsed_metadata[values[0].strip.to_sym] = values[1]
      end 

      # Confirm metadata has been parsed for each field as expected
      # See config/initializers/bulkrax.rb for parser configuration
      etd_metadata.each do |field, values|
        values.each { |value| expect(parsed_metadata[field]).to include(value) }
      end

      # Click through to the Etd
      page.find('strong', text: 'Etd Link').first(:xpath, './following-sibling::a').click

      # Wait to find title on Etd view
      page.find('h1', text: etd_metadata[:title].first, wait: 30)

      # Check files are attached
      # See create_etd_spec.rb for verifications on full set of Etd fields
      etd_metadata[:file].each { |file| expect(page).to have_content file }
      save_screenshot
    end
  end

  context 'as a Library staff user' do
    let(:staff_user) { User.find_by(email: 'staff_user@example.com') }

    before { login_as staff_user }

    scenario 'is not authorized to manage Importers' do
      visit 'importers'
      expect(page).to have_content 'You are not authorized to access this page'

      visit 'importers/new'
      expect(page).to have_content 'You are not authorized to access this page'
    end
  end

  context 'as a basic user' do
    let(:basic_user) { User.find_by(email: 'basic_user@example.com') }

    before { login_as basic_user }

    scenario 'is not authorized to manage Importers' do
      visit 'importers'
      expect(page).to have_content 'You are not authorized to access this page'      

      visit 'importers/new'
      expect(page).to have_content 'You are not authorized to access this page'
    end
  end

  context 'as a user who is not logged in' do
    scenario 'is redirected to login page' do
      visit 'importers'
      expect(page).to have_content 'You need to sign in or sign up before continuing'

      visit 'importers/new'
      expect(page).to have_content 'You need to sign in or sign up before continuing'      
    end      
  end

end