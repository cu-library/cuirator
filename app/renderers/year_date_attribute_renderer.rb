
class YearDateAttributeRenderer < Hyrax::Renderers::DateAttributeRenderer
      
  def attribute_value_to_html(value)
    # @todo add date parsing
    value[0,4]
  end
  
end
