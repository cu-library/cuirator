require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'View a fileset', js: true do
  let(:work) { FactoryBot.create(:public_work_with_public_file) }

  context 'when not logged in' do
    scenario 'Analytics button should not be displayed' do
      file_set_id = work.file_sets.first.id
      visit '/concern/parent/' + work.id + '/file_sets/' + file_set_id
      expect(page).to have_no_content('Analytics')      
      
    end
  end
end