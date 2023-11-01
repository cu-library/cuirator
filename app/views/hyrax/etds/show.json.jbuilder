# Overridden to filter out ETD fields shown in public JSON response
# frozen_string_literal: true
@curation_concern = Wings::ActiveFedoraConverter.convert(resource: @curation_concern) if
  @curation_concern.is_a? Hyrax::Resource

json.extract! @curation_concern, *[:id] + @curation_concern.class.fields.reject { |f| [:has_model].union(@presenter.json_admin_properties).include? f }
json.version @curation_concern.try(:etag)