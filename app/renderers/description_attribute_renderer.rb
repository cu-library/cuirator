# app/renderers/description_attribute_renderer.rb

=begin
    All we are doing with this renderer is overwriting attribute_value_to_html method to include all its previous functions but also 
    format any field that uses this renderer. For our purpose it will convert the html line breaks that is not seen by <textarea> into 
    the correct formatting that we seek. 
=end

# Note if we want to overwrite these method its must be as follow <NameofclassAttributeRenderer> and the name of the file must match
class DescriptionAttributeRenderer < Hyrax::Renderers::AttributeRenderer
    def attribute_value_to_html(value)
        simple_format(value)
    end
end

