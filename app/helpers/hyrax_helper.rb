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
    # Only one value provided in :has_model_ssim
    work_type = options[:document][:has_model_ssim].first

    # Date Created field permits multiple values in all work types
    # Facet value -- should always be a YYYY formatted date
    # Facet label -- if work type is ETD, should be a YYYY formatted date
    # @todo date parsing
    safe_join(options[:value].map { |value| link_to_facet_term(value[0,4], (work_type == "Etd") ? value[0,4] : value, "date_created_year_ssim") }, ", ")
  end

  def link_to_facet_term(value, label, field)
    path = main_app.search_catalog_path(search_state.add_facet_params_and_redirect(field, value))
    link_to(label, path)
  end

  # Facet view helpers

  def degree_level_term value
    ::DegreeLevelsService.label(value)
  end

  def language_term value
    ::LanguagesService.label(value)
  end

  # Indexing helpers

  # Used in Work, Research Work, and Etd indexers to parse a
  # YYYY-format date for Date Created facet and in Etd display
  def date_created_year(value)
    # YYYY-MM-DD format date is expected, other full-date formats may be provided
    year_date = Date.parse(value).year.to_s

    # If not, try a YYYY format date
    year_date ||= Date.strptime(value, "%Y").year.to_s
  rescue
    # Unknown format. Display value as entered so it's visible for clean-up
    value
  end

end
