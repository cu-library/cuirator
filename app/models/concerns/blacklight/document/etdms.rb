# frozen_string_literal: true
require 'builder'

# Register export format for OAI-ETDMS
# See Blacklight: app/models/concerns/blacklight/document/export.rb
module Blacklight::Document::Etdms
  def self.extended(document)
    Blacklight::Document::DublinCore.register_export_formats(document)
  end

  def self.register_export_formats(document)
    document.will_export_as(:xml)
    document.will_export_as(:etdms_xml, 'text/xml')
    document.will_export_as(:oai_etdms_xml, 'text/xml')
  end

  def etdms_field_names
    # order matters! 
    [
      :title,
      :creator,
      :subject,
      :description,
      :publisher,
      :contributor,
      :date,
      :type,
      :identifier,
      :oai_etdms_identifier, # additional identifiers in ETDMS records for LAC; see app/models/solr_document.rb
      :language,
      :rights
    ]
  end

  def etdms_degree_field_names
    # elements nested under <degree>, in order:
    [
      :name,
      :level,
      :discipline,
      :grantor
    ] 
  end

  # For valid ETDMS-XML:
  #   1. Order matters.
  #   2. The following elements must be present but can be empty. If no values provided, output empty tags.
  #      - title
  #      - creator
  #      - subject
  #      - type
  #      - identifier
  #   3. The following elements must be present and CAN'T be empty. But if no value provided,
  #      it's a metadata error that needs to be fixed. Provide empty tag & fix on harvesting error.
  #      - date
  def etdms_required_field_names
    [
      :title,
      :creator,
      :subject,
      :type,
      :identifier,
      :date
    ]
  end

  def export_as_oai_etdms_xml
    xml = Builder::XmlMarkup.new
    xml.tag!("oai_etdms:thesis",
             'xmlns:oai_etdms' => "http://www.ndltd.org/standards/metadata/etdms/1.0/",
             'xmlns:thesis' => "http://www.ndltd.org/standards/metadata/etdms/1.0/",
             'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
             'xsi:schemaLocation' => %(http://www.ndltd.org/standards/metadata/etdms/1.0/ http://www.ndltd.org/standards/metadata/etdms/1.0/etdms.xsd)) do

      # fetch semantic values hash
      semantic_values = to_semantic_values()

      etdms_field_names.each do |field|
        # provide empty string for required elements
        semantic_values[field] = '' if field.in?(etdms_required_field_names) and semantic_values[field].empty?

        # Output DC-ish elements
        Array.wrap(semantic_values[field]).each do |v|
          xml.tag! "thesis:#{field.to_s.gsub('oai_etdms_', '')}", v
        end
      end

      # Add degree-specific field names under <thesis:degree> parent element
      xml.tag! 'thesis:degree' do
        etdms_degree_field_names.each do |field|
          Array.wrap(semantic_values[field]).each do |v|
            xml.tag! "thesis:#{field}", v
          end
        end
      end
    end
    xml.target!
  end

  alias_method :export_as_xml, :export_as_oai_etdms_xml
  alias_method :export_as_etdms_xml, :export_as_oai_etdms_xml

end
