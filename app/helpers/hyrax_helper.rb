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

  # Index view helper to fetch and link Degree Level term by id
  def link_degree_level_term options
    # Keep field info in catalogue controller
    raise ArgumentError unless options[:config] && options[:config].helper_method_link_field
    term_id = options[:value].first
    term_label = ::DegreeLevelsService.label(term_id)
    path = main_app.search_catalog_path(search_state.add_facet_params_and_redirect(options[:config].helper_method_link_field, term_id))
    link_to(term_label, path)
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

  def degree_level_by_id value
    ::DegreeLevelsService.label(value)
  end

  def language_term value
    ::LanguagesService.label(value)
  end

end
