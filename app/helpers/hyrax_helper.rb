# frozen_string_literal: true
module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior

  def application_name
    'Carleton University Institutional Repository'
  end

  def header_name
    return ENV.fetch('HYRAX_HEADER_NAME', 'Institutional Repository')
  end

  def institution_name
    'Carleton University'
  end

  def institution_name_full
    'Carleton University'
  end

  # Blacklight helper_methods

  # Index view helpers

  def degree_level_facet(options)
    
    value = options[:value].first
    label = ::DegreeLevelsService.label(value)
    
    link_to_facet_term(value, label, 'degree_level_sim')

  end

  def date_created_facet(options)
    
    value = options[:value].map
    
    date = value.first
    date = date[0,4]
    work_type = options[:document][:has_model_ssim]

    if work_type[0] == "Etd"
      link_to_facet_term(date, value.first, "date_created_year_ssim")    
    else
      safe_join(options[:value].map { |value| link_to_facet_term(value, value, "date_created_year_ssim") }, ", ")
    end
  end

  def link_to_facet_term(value, label, field)
    path = main_app.search_catalog_path(search_state.add_facet_params_and_redirect(field, value))
    link_to(label, path)
  end

  def contributor_search(options)
    value = options[:value].first
    match_data = value.match('^(.+?)\s*(\\(.+?\\))?$')
    unless match_data.nil?
      contributor = match_data[1] || ""
      role = match_data[2] || ""
      link = link_to_field("all_fields", contributor)
      link += " " + ERB::Util.h(role) if role
    end
  end

  # Facet view helpers

  def degree_level_term value
    ::DegreeLevelsService.label(value)
  end

  def language_term value
    ::LanguagesService.label(value)
  end

end
