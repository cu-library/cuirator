require 'rails_helper'

RSpec.feature 'Create a work', js: true do

  # Rquired metadata
  let(:work_title) { "Create a generic work " + Time.new.strftime("%Y-%m-%d %H:%M:%S") }
  let(:resource_type) { "Report" }

  # Optional metadata
  let(:creator) { "Surname, Given Name" }
  let(:date_created) { "2023-11-30" }
  let(:abstract) { "An abstract is a brief summary of the work." }

  context 'as an admin user' do
    # attributes for admin user seeded in db
    let(:user_attributes) { {email: 'admin_user@example.com', password: 'admin_password'} }
    include_examples 'Create and save work'
  end

  context 'as a Library staff user' do
    # attributes for staff user seeded in db
    let(:user_attributes) { {email: 'staff_user@example.com', password: 'staff_password'} }
    include_examples 'Create and save work'
  end

  context 'not permitted as a basic user' do
    let(:user_attributes) { {email: 'basic_user@example.com', password: 'basic_password'} }

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

      # Confirm logged-in user doesn't have option to create a new work
      click_link "Works"
      expect(page).not_to have_content "Add New Work"

      # Log out user
      visit '/users/sign_out'
      expect(page).to have_content "Signed out successfully"
    end
  end

end