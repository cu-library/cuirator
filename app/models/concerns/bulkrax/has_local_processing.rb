# frozen_string_literal: true

module Bulkrax::HasLocalProcessing
  # This method is called during build_metadata
  # add any special processing here, for example to reset a metadata property
  # to add a custom property from outside of the import data
  def add_local
    add_geonames
    restore_linebreaks
  end

    # Use Geonames URIs to create a based_near_attributes hash for creating, 
    # updating Hyrax::ControlledVocabulary::Location attributes
    def add_geonames
      # get import file column name & split pattern from Bulkrax config
      source_field = get_source_field("based_near")
      
      if source_field and raw_metadata.has_key?(source_field)
        geonames_entries = raw_metadata[source_field].to_s.split(Regexp.new(get_split_pattern(source_field)))
  
        # remove values parsed into work's based_near attribute
        parsed_metadata.delete("based_near")
  
        # ... add based_near_attributes expected in create, update
        parsed_metadata["based_near_attributes"] ||= {}
  
        # filter out anything that's not a URI
        geonames_uris = geonames_entries.map { |entry| sanitize_uri(entry) }.compact
  
        # add remaining URIs to based_near_attributes
        geonames_uris.each_with_index do |value, i|
          parsed_metadata["based_near_attributes"][i.to_s] = { "id" => value }
        end
      end
    end

  # Import data may contain line breaks in block text fields for readability, in
  # attributes where the order of text blocks matters, e.g., description, abstract
  # Bulkrax removes line breaks when processing import data at 
  #   https://github.com/samvera-labs/bulkrax/blob/659887008387db29930239bb9f98f66a5845e14f/app/matchers/bulkrax/application_matcher.rb#L28
  # For now, restore line breaks from raw metadata
  def restore_linebreaks
    # Fields with displayed with local renderer that retains line breaks
    [ "description", "abstract", "rights_notes", "access_right", "internal_note" ].each do |field|
      source_field = get_source_field(field)
      next unless source_field

      if raw_metadata.has_key?(source_field)
        parsed_metadata[field] = raw_metadata[source_field].to_s.split(Regexp.new(get_split_pattern(field)))
      end
    end
  end

  def get_source_field(field) 
    # get import file column name Bulkrax config
    unless Bulkrax.field_mappings["Bulkrax::CsvParser"][field].nil?
      return Bulkrax.field_mappings["Bulkrax::CsvParser"][field][:from]&.first.to_s
    end
  end

  def get_split_pattern(field)
    # get field split pattern from Bulkrax config or use default
    unless Bulkrax.field_mappings["Bulkrax::CsvParser"][field].nil?
      split_pattern =  Bulkrax.field_mappings["Bulkrax::CsvParser"][field][:split]&.to_s
    end

    split_pattern ||= "[|]{3}"
  end

  def sanitize_uri(value)
    return unless value.match?(::URI::DEFAULT_PARSER.make_regexp)

    # trim & add trailing forward slash unless one is already present
    value = value.strip.chomp
    value << '/' unless value.match?(%r{/$})
    value
  end

end
