Qa.config do |config|
  # Adjust labels on Geonames authorities
  # See https://github.com/samvera/questioning_authority/blob/main/lib/qa/authorities/geonames.rb
  Qa::Authorities::Geonames.label = lambda do |item|
    labels = [ item['countryName'], item['adminName1'] ] 
    # Don't include name if it repeats admin name (prov, state, region etc) or country name
    labels << item['name'] unless labels.include?( item['name'] )
    # Filter out nil and blank admin names 
    labels.compact.reject { |c| c.empty? }.reverse.join(', ')
  end

  # When enabled, CORS headers will be added to the responses for search and show.  `OPTIONS` method will also be supported.
  # Uncomment one of the lines below to enable or disable CORS headers.  This configuration defaults to disabled when not set.
  # More information on CORS headers at: https://fetch.spec.whatwg.org/#cors-protocol
  # config.enable_cors_headers
  # config.disable_cors_headers

  # Provide a token that allows reloading of linked data authorities through the controller
  # action '/reload/linked_data/authorities?auth_token=YOUR_AUTH_TOKEN_DEFINED_HERE' without
  # requiring a restart of rails. By default, reloading through the browser is not allowed
  # when the token is nil or blank.  Change to any string to control who has access to reload.
  # config.authorized_reload_token = 'YOUR_AUTH_TOKEN_DEFINED_HERE'

  # For linked data access, specify default language for sorting and selection.  The default is only used if a language is not
  # specified in the authority's configuration file and not passed in as a parameter.  (e.g. :en, [:en], or [:en, :fr])
  # config.default_language = :en

  # When true, prevents ldpath requests from making additional network calls.  All values will come from the context graph
  # passed to the ldpath request.
  # config.limit_ldpath_to_context = true

  # Define default behavior for property_map.optional? when it is not defined in the configuration for a property.
  # When false, properties that do not override default optional behavior will be shown whether or not the property has a value in the graph.
  # When true, properties that do not override default optional behavior will not be shown whn the property does not have a value in the graph.
  # config.property_map_default_for_optional = false

  # IP data including IP address, city, state, and country will be logged with each request.
  # When false, IP data is logged
  # When true, IP data will not be logged (default for backward compatibility)
  # config.suppress_ip_data_from_log = true
end
