# services/languages_service.rb
module LanguagesService
  mattr_accessor :authority
  self.authority = Qa::Authorities::Local.subauthority_for('languages')
  
  def self.select_all_options
    authority.all.map do |element|
      [element[:label], element[:id]]
    end
  end
  
  def self.label(id)
    authority.find(id).fetch('term') rescue id
  end
end