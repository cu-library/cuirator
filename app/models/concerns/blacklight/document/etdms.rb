# frozen_string_literal: true

require 'builder'

# See Blacklight: app/models/concerns/blacklight/document/export.rb
module Blacklight
  module Document
    module Etdms
      def self.extended(document)
        return unless Blacklight::Document::Etdms.can_disseminate_thesis?(document)

        Blacklight::Document::Etdms.register_export_formats(document)
      end

      def self.register_export_formats(document)
        document.will_export_as(:xml)
        document.will_export_as(:etdms_xml, 'text/xml')
        document.will_export_as(:oai_etdms_xml, 'text/xml')
      end

      def self.can_disseminate_thesis?(document)
        return unless Blacklight::Document::Etdms.thesis?(document)

        # check thesis & licence agreements
        # if there are no agreements, thesis was acquired before automated CURVE
        # deposit and LAC licence was confirmed before digitization & deposit to IR
        can_disseminate_thesis ||= !document.keys.include?('agreement_tesim')

        # If agreements ARE present, thesis must be licenced to Carleton AND LAC
        can_disseminate_thesis ||=
          Blacklight::Document::Etdms.thesis_licence?(document) &&
          Blacklight::Document::Etdms.lac_licence?(document)

        # If licenced, thesis can be disseminated for harvesting
        can_disseminate_thesis
      end

      def self.thesis?(document)
        # Check work type: don't rely on resource type
        document['has_model_ssim']&.include?('Etd')
      end

      def self.thesis_licence?(document)
        # Confirm thesis licence agreement -- see config/authorities/agreements.yml
        # Must have Carleton University Thesis Licence Agreement OR Licence to Carleton University
        document['agreement_tesim']&.include?('https://repository.library.carleton.ca/concern/works/pc289j04q') ||
          document['agreement_tesim']&.include?('https://repository.library.carleton.ca/concern/works/ng451h485')
      end

      def self.lac_licence?(document)
        # Confirm LAC licence agreement -- see config/authorities/agreements.yml
        # Must have LAC Non-Exclusive Licence OR LAC Non-Exclusive Licence, 2020-2025
        document['agreement_tesim']&.include?('https://repository.library.carleton.ca/concern/works/tt44pm84n') ||
          document['agreement_tesim']&.include?('https://repository.library.carleton.ca/concern/works/6h440t871')
      end

      def etdms_field_names
        # order matters!
        # additional oai_etdms_identififer required by LAC: see app/models/solr_document.rb
        %i[
          title
          creator
          subject
          description
          publisher
          contributor
          date
          type
          identifier
          oai_etdms_identifier
          language
          rights
        ]
      end

      def etdms_degree_field_names
        # elements nested under <degree>, in order:
        %i[
          name
          level
          discipline
          grantor
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
        %i[
          title
          creator
          subject
          type
          identifier
          date
        ]
      end

      def export_as_oai_etdms_xml
        # raises exception on ListRecords verb with metadataPrefix = oai_etdms
        raise OAI::FormatException unless self.export_formats.include?(:etdms_xml)

        xml = Builder::XmlMarkup.new
        xml.tag!('oai_etdms:thesis',
                 'xmlns:oai_etdms' => "http://www.ndltd.org/standards/metadata/etdms/1.0/",
                 'xmlns:thesis' => "http://www.ndltd.org/standards/metadata/etdms/1.0/",
                 'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
                 'xsi:schemaLocation' => %(http://www.ndltd.org/standards/metadata/etdms/1.0/ http://www.ndltd.org/standards/metadata/etdms/1.0/etdms.xsd)) do
          # fetch semantic values hash
          semantic_values = to_semantic_values

          etdms_field_names.each do |field|
            # If element is required but no value is available, OAI ETDMS schema requires an empty element
            semantic_values[field] = '' if field.in?(etdms_required_field_names) && semantic_values[field].empty?

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

      alias export_as_xml export_as_oai_etdms_xml
      alias export_as_etdms_xml export_as_oai_etdms_xml
    end
  end
end
