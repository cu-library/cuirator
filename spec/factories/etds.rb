# frozen_string_literal: true

FactoryBot.define do
  factory :etd do
    # Required metadata
    title { ["Thesis or dissertation title #{Time.new.strftime('%Y-%m-%d %H:%M:%S')}"] }
    creator { ['Surname, Given Name'] }
    resource_type { ['Thesis'] }
    degree_level { '1' } # Master's degree
    degree { 'Master of Science (M.Sc.)' }
    degree_discipline { 'Engineering' }

    # Optional metadata commonly provided for Etds
    contributor { ['Person, First Name (Thesis advisor)'] }
    subject { ['Subject Area', 'Subject Area -- Ontario', 'Subject Area -- 20th century'] }
    abstract { ['A summary of the work.'] }
    publisher { ['Carleton University'] }
    date_created { ['2022-04-10'] }
    identifier { ['https://doi.org/10.22215/2023-12345'] }
    language { ['eng'] }
    rights_notes { ['Copyright (c) 2022 the author.'] }

    # Optional, limited-access metadata (admin, Library staff only)
    internal_note { ['This is an internal note added by the Metadata team.'] }

    # Carleton University Thesis Licence Agreement and LAC licence
    # See config/authorities.yml
    agreement do
      [
        'https://repository.library.carleton.ca/concern/works/pc289j04q',
        'https://repository.library.carleton.ca/concern/works/6h440t871'
      ]
    end

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

    # Public ETD with public file, licenced to Carleton and LAC
    factory :public_etd_with_public_file, traits: [:public] do
      before(:create) do |etd, context|
        etd.ordered_members << create(:public_file)
      end
    end

    # Public ETD with private file, licenced to Carleton and LAC
    factory :public_etd_with_private_file, traits: [:public] do
      before(:create) do |etd, context|
        etd.ordered_members << create(:private_file)
      end
    end

    # Private ETD with private file, licenced to Carleton and LAC
    factory :private_etd_with_private_file, traits: [:private] do
      before(:create) do |etd, context|
        etd.ordered_members << create(:private_file)
      end
    end

    # Public ETD with CU & LAC licences, but no files
    factory :public_etd, traits: [:public]
  end
end
