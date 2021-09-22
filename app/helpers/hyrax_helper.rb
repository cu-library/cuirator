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

  # Blacklight helper_method
  # Index view helper to fetch and link Degree Level term by id
  def link_degree_level_term options
    # Keep field info in catalogue controller
    raise ArgumentError unless options[:config] && options[:config].helper_method_link_field
    term_id = options[:value].first
    term_label = ::DegreeLevelsService.label(term_id)
    path = main_app.search_catalog_path(search_state.add_facet_params_and_redirect(options[:config].helper_method_link_field, term_id))
    link_to(term_label, path)
  end

  # Blacklight helper_method
  # Facet view helper 
  def degree_level_by_id value
    ::DegreeLevelsService.label(value)
  end

end
