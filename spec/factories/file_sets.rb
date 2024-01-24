# frozen_string_literal: true

# A very basic factory for FileSets, based o
# https://github.com/UNC-Libraries/hy-c/blob/main/spec/factories/file_sets.rb

FactoryBot.define do

  factory :file_set do

    title { ['Generic work'] } 

    transient do
      # For now fetch user seeded in db; later, replace w/ users factory
      depositing_user { User.find_by(email: 'staff_user@example.com') }

      # Set generic work PDF as default content
      content { File.open("#{RSpec.configuration.fixture_path}/generic_work.pdf") }
    end

    # Use transient user to set file_set attributes
    after(:build) do |file_set, context|
      file_set.apply_depositor_metadata(context.depositing_user.user_key)
    end

    # Upload file, if file content defined
    after(:create) do |file_set, context|
      Hydra::Works::UploadFileToFileSet.call(file_set, context.content) if context.content
    end

    # Set file visibility to Public
    trait :public_visibility do
      read_groups { ['public'] }
    end

    # Set file visibility to Private
    trait :private_visibility do 
      # Default if no read_groups defined
    end

    # shortcuts to create public, private files
    factory :public_file, traits: [:public_visibility]
    factory :private_file, traits: [:private_visibility]
  end

end