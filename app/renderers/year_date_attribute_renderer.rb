# app/renderers/year_date_attribute_renderer.rb

# Etds store YYYY-MM-DD submission date in Date Created
# Format for display as YYYY to correspond w/ date on title page
class YearDateAttributeRenderer < Hyrax::Renderers::DateAttributeRenderer

  def attribute_value_to_html(value)
    # YYYY-MM-DD format date is expected, other full-date formats may be provided
    year_date = Date.parse(value).year.to_s

    # If not, try a YYYY format date
    year_date ||= Date.strptime(value, "%Y").year.to_s
  rescue
    # Unknown format. Display value as entered so it's visible for clean-up
    value
  end
  
end
