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

    # Date Created facets on YYYY-formatted dates indexed in date_created_year_ssim
    # Create facet link:
    # Facet value -- always be a YYYY formatted date; use helper to parse YYYY date
    # Facet label -- if ETD, use helper to parse YYYY date; otherwise, show value as-is
    facet_links = options[:value].map do |value|
      year = date_created_year(value)
      link_to_facet_term(year, work_type == "Etd" ? year : value, "date_created_year_ssim")
    end
    safe_join(facet_links, ", ")
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
