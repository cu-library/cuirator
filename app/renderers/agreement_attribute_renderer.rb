# app/renderers/agreement_attribute_renderer.rb
class AgreementAttributeRenderer < Hyrax::Renderers::AttributeRenderer
  def attribute_value_to_html(value)
    # fetch term for value
    term = ::AgreementsService.label(value)

    # check value is valid uri
    begin
      parsed_uri = URI.parse(value)
    rescue URI::InvalidURIError
      nil
    end

    if parsed_uri.nil?
      ERB::Util.h(term)
    else
      %(<a href=#{ERB::Util.h(value)} target="_blank">#{term}</a>)
    end
  end
end