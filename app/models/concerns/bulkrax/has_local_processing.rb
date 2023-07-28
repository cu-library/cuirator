# frozen_string_literal: true

module Bulkrax::HasLocalProcessing
  # This method is called during build_metadata
  # add any special processing here, for example to reset a metadata property
  # to add a custom property from outside of the import data
  def add_local
    add_geonames
  end

  def add_geonames
    # get import file column name & split pattern from Bulkrax config
    unless Bulkrax.field_mappings["Bulkrax::CsvParser"]["based_near"].nil?
      geonames_field = Bulkrax.field_mappings["Bulkrax::CsvParser"]["based_near"][:from]&.first.to_s
      geonames_split = Bulkrax.field_mappings["Bulkrax::CsvParser"]["based_near"][:split]&.to_s
    end

    # set defaults if not mapped in config
    geonames_field ||= "based_near"
    geonames_split ||= "[|]{3}"

    if raw_metadata.has_key?(geonames_field)
      geonames_entries = raw_metadata[geonames_field].to_s.split(Regexp.new(geonames_split))

      # remove values parsed into work's based_near attribute
      parsed_metadata.delete("based_near")

      # ... add based_near_attributes expected in create, update
      parsed_metadata["based_near_attributes"] ||= {}

      # filter out anything that's not a URI
      geonames_uris = geonames_entries.map { |entry| sanitize_uri(entry) }.compact

      # add remaining URIs to based_near_attributes
      geonames_uris.each_with_index do |value, i|
        parsed_metadata["based_near_attributes"][i] = { "id" => value }
      end
    end
  end

  def sanitize_uri(value)
    return unless value.match?(::URI::DEFAULT_PARSER.make_regexp)

    # trim & add trailing forward slash unless one is already present
    value = value.strip.chomp
    value << '/' unless value.match?(%r{/$})
    value
  end

end
