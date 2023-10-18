# Overridden from Blacklight to limit fields in JSON response: show id,
# source, and index fields configured in app/controllers/catalog_controller.rb
json.response do
  json.docs @presenter.documents do |document|
    json.id document.id
    json.set! "source_tesim", document["source_tesim"].nil? ? [] : document["source_tesim"]
    index_fields(document).each do |field_name, field|
      json.set! field_name, document[field_name].nil? ? [] : document[field_name]
    end
  end
 json.facets @presenter.search_facets_as_json
 json.pages @presenter.pagination_info
end
