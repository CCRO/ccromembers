class Company < ActiveRecord::Base

  has_many :subscriptions, :as => :owner

  has_many :people
  has_many :documents, :as => :owner
  has_many :pages, :as => :owner 
  has_many :posts, :as => :owner 
  has_many :messages, :as => :owner
  has_many :responses  

  belongs_to :primary_contact, :class_name => 'Person', :foreign_key => 'primary_person_id'
  belongs_to :billing_contact, :class_name => 'Person', :foreign_key => 'billing_person_id'
  
  mount_uploader :logo_pic, LogoUploader

  before_save :check_contacts
  after_initialize :first_is_admin

  def primary_person
    unless self.primary_person_id.nil?
      person = Person.find_by_id(self.primary_person_id)
    else
      person = nil
    end
  end
  
  def level
    if self.leadership?
      'leadership'
    elsif self.company_member?
      'company_member'
    else
      'none'
    end
  end

  def leadership?
    self.subscriptions.active.pluck(:product).include? 'leadership'             
  end
  
  def company_member?
    self.subscriptions.active.pluck(:product).include? 'company_member'
  end
 
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
