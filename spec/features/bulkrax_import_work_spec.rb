require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Import a Work with Bulkrax', js: true do

  # This spec does user POV check on local processing applied during Bulkrax
  # imports: line breaks in block text fields and setting up GeoNames URLs as
  # based_near attributes. 
  # These changes would be better handled in a spec to verify values parsed 
  # by Bulkrax::CsvEntry according to local config & also invokes local processing

  context 'as an admin user' do
    let(:admin_user) { User.find_by(email: 'admin_user@example.com') }

    # Importer metadata
    let(:importer_name) { 'Bulkrax Work importer ' + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
    let(:default_admin_set) { 'Default Admin Set' }
    let(:csv_parser) { 'CSV - Comma Separated Values' }
    let(:bulkrax_import_file) { File.join(fixture_path, 'bulkrax_import_work.zip') }

    # Values defined in metadata.csv in bulkrax_import_etd.zip
    let(:source_identifier) { '01036fa9-e80a-4018-bf78-ac6384172ab2' }
    let(:title) { 'Generic work imported by Bulkrax' }
    let(:locations) { ['Canada', 'United States'] }
    let(:descriptions) { ['This is a public work.', 'This description includes a line break.'] }

    before { login_as admin_user }

    scenario 'can create and run an importer' do
      visit '/importers'
      click_on 'New'
      expect(page).to have_content 'New Importer'

      fill_in('Name', with: importer_name)
      select(default_admin_set, from: 'Administrative Set')
      select(csv_parser, from: 'Parser')

      # Upload zip w/ metadata.csv and files
      choose 'Upload a File'
      attach_file('importer[parser_fields][file]', bulkrax_import_file, make_visible: true)
      click_on 'Create and Import'

      # 'Create and Import' loads Importers list. Confirm importer has been created.
      expect(page).to have_content importer_name

      # Click through to importer view
      page.find('a', text: importer_name).click
      expect(page).to have_content "Importer: #{importer_name}"

      # Confirm work entry has been found and imported
      work_entries = page.find('#work-entries')
      expect(work_entries).to have_content source_identifier

      # Wait for work import to complete. Find a better way to to do this.
      Timeout.timeout(Capybara.default_max_wait_time) do
        loop do
          import_status = work_entries.find_all('td')
          break if import_status.find { |node| node.text.include? 'Complete' }
          sleep(5)
          page.refresh
        end
      end
      expect(page).to have_content 'Complete'

      # Navigate to imported work
      click_on source_identifier
      page.find('p', text: 'Identifier: ' + source_identifier)

      # Click through to the Work
      page.find('strong', text: 'Work Link').first(:xpath, './following-sibling::a').click

      # Wait to find title on Etd view
      page.find('h1', text: title)

      # Expect Description blocks to be formatted in separate paragraphs
      descriptions.each { |description| page.find('p', text: description) }

      # Find Locations
      locations.each { |location| expect(page).to have_content location }
    end
  end

end