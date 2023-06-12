# app/renderers/contributor_attribute_renderer.rb
# Renderer used in attribute rows for ETD show page
# https://github.com/cu-library/cuirator/blob/main/app/views/hyrax/etds/_attribute_rows.html.erb
# Extract contributor name and link to ...
class ContributorAttributeRenderer < Hyrax::Renderers::LinkedAttributeRenderer
 
    def li_value(value)
      # Contributor name and role received from FGPA in "Name text (role text)" format
      # Value may contain additional or nested sets of parentheses
      # Role text is contained is right-most set of parentheses
      match_data = value.scan(/\((?>[^)(]+|\g<0>)*\)/)

      unless match_data.nil?
        contributor_role = match_data.last || ""

        # Remove contributor role at right-anchored end of contributor text
        # Escape regexp chars in role before matching/replacing in text 
        contributor_name = value.sub(/\s*#{Regexp.escape(contributor_role)}$/, "") || ""

        # Link name text to ... 
        link = link_to(ERB::Util.h(contributor_name), search_path(contributor_name))
        link += " " + contributor_role unless contributor_role.empty?
      end
    end
  end