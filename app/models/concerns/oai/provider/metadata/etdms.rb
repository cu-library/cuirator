module OAI::Provider::Metadata

  # Simple implementation of the Etdms metadata format
  class Etdms < Format
    def initialize
      @prefix = 'oai_etdms'
      @schema = 'http://www.ndltd.org/standards/metadata/etdms/1.0/etdms.xsd'
      @namespace = 'http://www.ndltd.org/standards/metadata/etdms/1.0/'
      @element_namespace = 'thesis'
    end

    def header_specification
      {
        'xmlns:oai_etdms' => "http://www.ndltd.org/standards/metadata/etdms/1.0/",
        'xmlns:thesis' => "http://www.ndltd.org/standards/metadata/etdms/1.0/",
        'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
        'xsi:schemaLocation' =>
          %{http://www.ndltd.org/standards/metadata/etdms/1.0/
            http://www.ndltd.org/standards/metadata/etdms/1.0/etdms.xsd}.gsub(/\s+/, ' ')
      }
    end

  end
end