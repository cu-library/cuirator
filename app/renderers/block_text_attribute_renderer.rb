# app/renderers/block_text_attribute_renderer.rb

# Allow line breaks in block text fields for readability
class BlockTextAttributeRenderer < Hyrax::Renderers::AttributeRenderer

    def attribute_value_to_html(value)
      # split on line breaks & filter out blanks
      # get li_value for each line and encode in paragraph tags
      block_text = value.split(/(?:\n\r?|\r\n?)/).compact.reject { |c| c.empty? }.map{ |para| "<p>" + li_value(para).strip + "</p>" }.join

      # add microdata attributes to outer <div> if present
      if microdata_value_attributes(field).present?
        "<div#{html_attributes(microdata_value_attributes(field))}>#{block_text}</div>"
      else
        block_text
      end

    end
end


