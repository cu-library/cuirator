# services/agreements_service.rb
module AgreementsService
  mattr_accessor :authority
  self.authority = Qa::Authorities::Local.subauthority_for('agreements')
  
  def self.select_all_options
    authority.all.map do |element|
      [element[:label], element[:id]]
    end
  end
  
  def self.label(id)
    authority.find(id).fetch('term') rescue id
  end
end