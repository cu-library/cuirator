
class YearDateAttributeRenderer < Hyrax::Renderers::DateAttributeRenderer
      
  def attribute_value_to_html(value)
    Date.parse(value).to_formatted_s(:year)
  end
  
end
