# app/renderers/contributor_attribute_renderer.rb
class ContributorAttributeRenderer < Hyrax::Renderers::LinkedAttributeRenderer
    def li_value(value)
      match_data = value.match('^(.+?)\s*(\\(.+?\\))?$')
      unless match_data.nil?
        contributor = match_data[1] || ""
        role = match_data[2] || ""
        link = link_to(ERB::Util.h(contributor), search_path(contributor))
        link += " " + ERB::Util.h(role) if role 
      end
    end
  end