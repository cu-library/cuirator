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
      :contributor,
      :subject,
      :abstract,
      :publisher,
      :date,
      :type,
      :identifier,
      :language,
      :rights
    ]
  end

  def etdms_degree_field_names
    # elements nested under <degree>
    [
      :name, # <-- this is not good
      :level,
      :discipline,
      :grantor
    ] 
  end

  def export_as_oai_etdms_xml
    xml = Builder::XmlMarkup.new
    xml.tag!("oai_etdms:thesis",
             'xmlns:oai_etdms' => "http://www.ndltd.org/standards/metadata/etdms/1.0/",
             'xmlns:thesis' => "http://www.ndltd.org/standards/metadata/etdms/1.0/",
             'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
             'xsi:schemaLocation' => %(http://www.ndltd.org/standards/metadata/etdms/1.0/ http://www.ndltd.org/standards/metadata/etdms/1.0/etdms.xsd)) do
      to_semantic_values.select { |field, _values| etdms_field_name? field  }.each do |field, values|
        Array.wrap(values).each do |v|
          xml.tag! "thesis:#{field}", v
        end
      end
      # add degree-specific field names under <thesis:degree> parent element
      xml.tag! 'thesis:degree' do
        to_semantic_values.select { |field, _values| etdms_degree_field_name? field  }.each do |field, values|
          Array.wrap(values).each do |v|
            xml.tag! "thesis:#{field}", v
          end
        end
      end
    end
    xml.target!
  end

  alias_method :export_as_xml, :export_as_oai_etdms_xml
  alias_method :export_as_etdms_xml, :export_as_oai_etdms_xml

  private

  def etdms_field_name? field
    etdms_field_names.include? field.to_sym
  end

  def etdms_degree_field_name? field
    etdms_degree_field_names.include? field.to_sym
  end
end
