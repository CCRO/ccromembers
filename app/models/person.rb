class Person < ActiveRecord::Base
  belongs_to :company  
  has_secure_password
  attr_accessible :name, :email,:company, :company_id, :highrise_id, :password, :password_confirmation
  validates_uniqueness_of :email
  before_save :check_contacts
  
  def primary_contact?
    (self.company && self.company.primary_contact == self)
  end

  def billing_contact?
    (self.company && self.company.billing_contact == self)
  end

  def role
    self.company.role if self.company
  end
  
  private
    
  def check_contacts
    if !self.new_record? && self.company_id_changed? && self.company_id_was
      previous_company = Company.find(self.company_id_was)
      previous_company.primary_contact = nil if previous_company.primary_contact == self
      previous_company.billing_contact = nil if previous_company.billing_contact == self
      previous_company.save if previous_company.changed?
      true
    else
      true
    end
  end
end
