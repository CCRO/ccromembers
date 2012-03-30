class Person < ActiveRecord::Base
  belongs_to :company 
  has_many :documents, :as => :owner 

  has_secure_password

  before_save :check_contacts
  before_validation :create_access_token

  attr_accessible :name, :email,:company, :company_id, :highrise_id, :password, :password_confirmation, :access_token

  validates_uniqueness_of :email
  
  validates_presence_of :password, :on => :create
  validates_presence_of :access_token
  validates_uniqueness_of :access_token

  
  def primary_contact?
    (self.company && self.company.primary_contact == self)
  end

  def billing_contact?
    (self.company && self.company.billing_contact == self)
  end

  def role
    self.company.role if self.company
  end
  
  def member?
    ['full-member', 'participating-member', 'member-emeritus', 'board'].include? self.role
  end
  
  def admin?
    self.role == 'administrator'
  end
  
  def to_xml(options={})
    options.merge!(:except => [:password_digest, :access_token, :created_at, :updated_at], :include => [:company => {:only => [:name]}])
    super(options)
  end

  def as_json(options={})
    options.merge!(:except => [:password_digest, :access_token, :created_at, :updated_at])
    super(options)
  end
  
  def send_password_reset
    generate_perishable_token
    self.perishable_token_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
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

  def create_access_token
    self.access_token = rand(36**8).to_s(36) if self.access_token.nil?
  end 
  
  def generate_perishable_token
    begin
      self.perishable_token = SecureRandom.urlsafe_base64
    end while Person.exists?(:perishable_token => self.perishable_token)
  end
  
end
