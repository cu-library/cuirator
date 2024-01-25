# frozen_string_literal: true

# A very gentle start with FactoryBot, based on
# https://github.com/UNC-Libraries/hy-c/blob/main/spec/factories/general.rb

FactoryBot.define do

  factory :work do
    # Required metadata
    title { ['Title for a generic work ' + Time.new.strftime("%Y-%m-%d %H:%M:%S")] }
    resource_type { ['Report'] }

    # Define transient attributes: these are only available in the factory block
    # & can be used to define / fetch / set additional work attributes
    transient do 
      # For now, fetch user and admin set seeded in db/seeds.rb, although 
      # these could/should be replaced w/ factories -- see file ref'd above
      depositing_user { User.find_by(email: 'staff_user@example.com') }
      default_admin_set { Hyrax::AdminSetCreateService.find_or_create_default_admin_set }
    end

    # Use transient user & admin_set objects to set Work attributes
    # See hook invocation order at https://thoughtbot.github.io/factory_bot/ref/build-strategies.html
    after(:build) do |work, context|
      work.apply_depositor_metadata(context.depositing_user.user_key)
      work.admin_set_id = context.default_admin_set.id.to_s
    end

    # Use traits to create works with different attributes
    trait :public do
      visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    end

    trait :private do 
      # default visibility is private
    end

    # Create a public work with a public file
    factory :public_work_with_public_file, traits: [:public] do
      before(:create) do |work, context|
        work.ordered_members << create(:public_file)
      end
    end

    # Create a public work with a private file 
    factory :public_work_with_private_file, traits: [:public] do
      before(:create) do |work, context|
        work.ordered_members << create(:private_file)
      end
    end
  end

end