# app/renderers/degree_level_faceted_attribute_renderer.rb
class DegreeLevelFacetedAttributeRenderer < Hyrax::Renderers::FacetedAttributeRenderer
  def li_value(value)
    link_to(ERB::Util.h(::DegreeLevelsService.label(value)), search_path(value))
  end
end