# frozen_string_literal: true

FactoryBot.define do

  factory :etd do
    # Required metadata
    title { ['Thesis or dissertation title ' + Time.new.strftime("%Y-%m-%d %H:%M:%S")] }
    creator { ['Surname, Given Name'] }
    resource_type { ['Thesis'] }
    degree_level { '1' } # Master's degree
    degree { 'Master of Science (M.Sc.)' }
    degree_discipline { 'Engineering' }

    # Optional, limited-access metadata (admin, Library staff only)
    internal_note { ['This is an internal note added by the Metadata team.'] }
    agreement { ['https://repository.library.carleton.ca/concern/works/pc289j04q'] } # Carleton University Thesis Licence Agreement

    transient do
      depositing_user { User.find_by(email: 'staff_user@example.com') }
      default_admin_set { Hyrax::AdminSetCreateService.find_or_create_default_admin_set }
    end

    after(:build) do |etd, context|
      etd.apply_depositor_metadata(context.depositing_user.user_key)
      etd.admin_set_id = context.default_admin_set.id.to_s
    end

    trait :public do
      visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    end

    trait :private do 
      # default visibility is private
    end

    factory :public_etd, traits: [:public]
  end
end