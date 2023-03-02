
class YearDateAttributeRenderer < Hyrax::Renderers::LinkedAttributeRenderer
      
  def attribute_value_to_html(value)
    value[0, 4]
  end
end
