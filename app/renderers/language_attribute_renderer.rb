# app/renderers/language_attribute_renderer.rb
class LanguageAttributeRenderer < Hyrax::Renderers::FacetedAttributeRenderer
  def li_value(value)
    link_to(ERB::Util.h(::LanguagesService.label(value)), search_path(value))
  end
end
