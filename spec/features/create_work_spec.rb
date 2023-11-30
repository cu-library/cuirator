require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Create a work', js: true do

  context 'as an admin user' do
    # find admin user seeded in db
    let(:user_attributes) do
      { email: 'admin@example.com' }
    end

    # find the user
    let(:user) do
      User.find_by(user_attributes)
    end

    # find or create default admin set
    let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }

    # Get default admin set permissions 
    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }

    # Use 'default' workflow for admin set (vs mediated deposit, or some other defined workflow)
    let(:workflow) { Sipity::Workflow.find_by!(name: 'default', permission_template: permission_template) }

    # Sipity::Agent is a proxy for an entity that can take an action -- user, group, etc
    let(:user_agent) { Sipity::Agent.where(proxy_for_id: user.id, proxy_for_type: 'User').first_or_create }

    # Rquired metadata
    # Assign a unique title, to run / find subsequent tests
    let(:work_title) { "Create a generic work " + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
    let(:resource_type) { "Report" }

    # Optional metadata
    let(:creator) { "Surname, Given Name" }
    let(:date_created) { "2023-11-30" }
    let(:abstract) { "An abstract is a brief summary of the work." }

    before do
      #  Hyrax::PermissionTemplateAccess models a single grant of access to an agent (user or group) on a PermissionTemplate
      Hyrax::PermissionTemplateAccess.create(
        permission_template: permission_template,
        agent_type: 'user',
        agent_id: user.user_key,
        access: 'deposit')

      # Assigns depositor role to deposit workflow for user agent
      Hyrax::Workflow::PermissionGenerator.call(roles: 'depositing', workflow: workflow, agents: user_agent)

      # Log in as admin user
      login_as user
    end

    scenario do
      # Navigate dashboard UI to create a new work
      visit '/concern/works/new'
    
      # Clear the cookie notice & confirm it's no longer visible
      # Otherwise, the new work's save button is not available to receive a click
      expect(page).to have_content "This site uses cookies"
      click_button "Ok. Got it."
      expect(page).not_to have_content "This site uses cookies"

      # Confirm user has option to create a new work
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

      # Save screenshots to help debug tests -- see spec/support/capybara.rb
      save_screenshot
    end
  end
end