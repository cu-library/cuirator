require 'rails_helper'

RSpec.feature 'Create a work', js: true do

  context 'as an admin user' do
    # attributes for admin user seeded in db
    let(:user_attributes) do
      { email: 'admin_user@example.com', password: 'admin_password' }
    end

    # Rquired metadata
    # Assign a unique title, to run / find subsequent tests
    let(:work_title) { "Create a generic work " + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
    let(:resource_type) { "Report" }

    # Optional metadata
    let(:creator) { "Surname, Given Name" }
    let(:date_created) { "2023-11-30" }
    let(:abstract) { "An abstract is a brief summary of the work." }

    scenario do
      # Navigate to login page
      visit '/users/sign_in'
      expect(page).to have_content "Log in"

      # Clear the cookie notice & confirm it's no longer visible
      # Otherwise, the new work's save button is not available to receive a click
      expect(page).to have_content "This site uses cookies"
      click_button "Ok. Got it."
      expect(page).not_to have_content "This site uses cookies"

      # Fill in username & password
      fill_in("Email", with: user_attributes[:email] )      
      fill_in("Password", with: user_attributes[:password])
      click_on("Log in")

      # Confirm logged-in user has view of Dashboard
      expect(page).to have_content "Dashboard"

      # Visit page to create a new work
      visit '/concern/works/new'
      expect(page).to have_content "Add New Work"

      # Switch to Files tab
      click_link "Files"
      expect(page).to have_content "Add files"

      # Upload file(s) 
      within('div#add-files') do
        attach_file('files[]', File.join(fixture_path, 'generic_work.pdf'), visible: false)
      end

      # Add required metadata
      click_link "Descriptions"
      fill_in("Title", with: work_title)
      select(resource_type, from: "Resource type")

      # With Selenium / Chromedriver, focus remains on the select box. Click
      # body to move focus outside select box so next element can be found.
      find("body").click
      
      # Add optional metadata
      click_on "Additional fields"
      fill_in("Creator", with: creator)      
      fill_in("Date Created", with: date_created)
      fill_in("Abstract", with: abstract)

      # Set work visibility Public
      choose('work_visibility_open')

      # Accept deposit agreement 
      check('agreement')

      # Uncomment to help debug flaky tests (visible elements not found, not clickable, etc.)
      # puts "Required metadata: #{page.evaluate_script(%{$('#form-progress').data('save_work_control').requiredFields.areComplete})}"
      # puts "Required files: #{page.evaluate_script(%{$('#form-progress').data('save_work_control').uploads.hasFiles})}"
      # puts "Agreement: #{page.evaluate_script(%{$('#form-progress').data('save_work_control').depositAgreement.isAccepted})}"

      click_on("Save")

      # Expect work files to be processing in the background
      expect(page).to have_content "Your files are being processed"

      # Required metadata
      expect(page).to have_content work_title
      expect(page).to have_content resource_type

      # Optional metadata
      expect(page).to have_content creator
      expect(page).to have_content date_created
      expect(page).to have_content abstract

      save_screenshot
    end
  end
end