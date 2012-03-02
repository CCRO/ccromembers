class Company < ActiveRecord::Base
  has_many :people
  belongs_to :primary_contact, :class_name => 'Person', :foreign_key => 'primary_person_id'
  belongs_to :billing_contact, :class_name => 'Person', :foreign_key => 'billing_person_id'
  
  before_save :check_contacts
  
  private
    
  def check_contacts
    unless self.new_record?
      (self.primary_contact.nil? || self.primary_contact.company == self) && (self.billing_contact.nil? || self.billing_contact.company == self )
    else
      true
    end
  end
end
