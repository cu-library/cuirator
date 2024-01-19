RSpec.shared_examples 'Create and save work' do

  # Shared scenario for admin & library-staff users to create a work
  scenario do
    # Navigate to the Dashboard
    visit '/dashboard'
    expect(page).to have_content "Dashboard"

    # Clear the cookie notice -- otherwise, sometimes blocks Save click
    click_button 'Ok. Got it.' if page.find('div.cookies-eu') 
    expect(page).not_to have_content 'This site uses cookies'

    # Visit page to create a new work
    click_link "Works"
    expect(page).to have_content "Add New Work"

    # Choose generic Work type
    click_on "Add New Work"
    choose "payload_concern", option: "Work"
    click_button "Create work"
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
    select language, from: 'Language'
    fill_in('Identifier', with: identifier)

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
    expect(page).to have_content language
    expect(page).to have_content identifier

    # Log out user
    visit '/users/sign_out'
    expect(page).to have_content "Signed out successfully"
  end
end