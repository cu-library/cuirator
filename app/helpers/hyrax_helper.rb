# frozen_string_literal: true
module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior

  def application_name
    'Digital Library'
  end

  def institution_name
    'Carleton University Library'
  end

  def  institution_name_full 
    'Carleton University Library'
  end

  # Blacklight helper_methods

  # Index view helpers

  def degree_level_facet(options)
    value = options[:value].first
    label = ::DegreeLevelsService.label(value)
    link_to_facet_term(value, label, 'degree_level_sim')
  end

  def language_facet(options)
    link_to_facet_term_list(options[:value], "language_sim")
  end

  def link_to_facet_term(value, label, field)
    path = main_app.search_catalog_path(search_state.add_facet_params_and_redirect(field, value))
    link_to(label, path)
  end

  def link_to_facet_term_list(values, field, empty_message = "", separator = ", ")
    return empty_message if values.blank?
    safe_join(values.map { |value| link_to_facet_term(value, ::LanguagesService.label(value), field) }, separator)
  end

  # Facet view helpers

  def degree_level_term value
    ::DegreeLevelsService.label(value)
  end

  def language_term value
    ::LanguagesService.label(value)
  end

end
