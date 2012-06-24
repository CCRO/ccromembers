class Company < ActiveRecord::Base

  has_many :subscriptions, :as => :owner

  has_many :people
  has_many :documents, :as => :owner 

  belongs_to :primary_contact, :class_name => 'Person', :foreign_key => 'primary_person_id'
  belongs_to :billing_contact, :class_name => 'Person', :foreign_key => 'billing_person_id'
  
  before_save :check_contacts
  after_initialize :first_is_admin
  
  def update_balance!
    if self.freshbooks_id.present?
       @fbc = Freshbooks.new
       self.balance = @fbc.get_client_amount_outstanding(self.freshbooks_id)
       self.save 
    end
  end
  handle_asynchronously :update_balance!

  private
    
  def check_contacts
    unless self.new_record?
      (self.primary_contact.blank? || self.primary_contact.company == self) && (self.billing_contact.blank? || self.billing_contact.company == self )
    else
      true
    end
  end
  
  def first_is_admin
    self.role = 'administrator' if Company.count == 0
  end
end
