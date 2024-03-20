# Override ruby-oai/lib/oai/provider.rb to register ETDMS as an OAI metadata format
# For implementation see app/models/concerns/oai/provider/metadata/etdms.rb 
# and app/models/concerns/blacklight/document/etdms.rb
OAI::Provider::Base.class_eval do
  register_format(OAI::Provider::Metadata::Etdms.instance)
end
