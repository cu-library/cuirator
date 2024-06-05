# frozen_string_literal: true

# A very gentle start with FactoryBot, based on
# https://github.com/UNC-Libraries/hy-c/blob/main/spec/factories/general.rb

FactoryBot.define do

    factory :research_work do
      # Required metadata
      title { ['Title for a generic research work ' + Time.new.strftime("%Y-%m-%d %H:%M:%S")] }
      resource_type { ['Report'] }
  
      # Optional, limited-access metadata (admin, Library staff only)
      internal_note { ['This is an internal note added by the Metadata team.'] }
  
      # Define transient attributes: these are only available in the factory block
      # & can be used to define / fetch / set additional research work attributes
      transient do 
        # For now, fetch user and admin set seeded in db/seeds.rb, although 
        # these could/should be replaced w/ factories -- see file ref'd above
        depositing_user { User.find_by(email: 'staff_user@example.com') }
        default_admin_set { Hyrax::AdminSetCreateService.find_or_create_default_admin_set }
      end
  
      # Use transient user & admin_set objects to set researchWork attributes
      # See hook invocation order at https://thoughtbot.github.io/factory_bot/ref/build-strategies.html
      after(:build) do |research_work, context|
        research_work.apply_depositor_metadata(context.depositing_user.user_key)
        research_work.admin_set_id = context.default_admin_set.id.to_s
      end
  
      # Use traits to create research works with different attributes
      trait :public do
        visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
      end
  
      trait :private do 
        # default visibility is private
      end
  
      # Create a public work with a public file
      factory :public_research_work_with_public_file, traits: [:public] do
        before(:create) do |research_work, context|
            research_work.ordered_members << create(:public_file)
        end
      end
  
      # Create a public work with a private file 
      factory :public_research_work_with_private_file, traits: [:public] do
        before(:create) do |research_work, context|
          research_work.ordered_members << create(:private_file)
        end
      end
    end
  
  end