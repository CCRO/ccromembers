class Person < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks
  include RMagick
  index_name INDEX_NAME
 
  mapping do
    indexes :id,           :index    => :not_analyzed
    indexes :name,        :analyzer => 'snowball', :boost => 100
    indexes :company_name,        :as => 'company_name', :analyzer => 'snowball', :boost => 50
    indexes :level,        :as => 'level', :analyzer => 'snowball', :boost => 75
    indexes :email,      :analyzer => 'snowball', :boost => 2
    indexes :bio,      :analyzer => 'snowball'
    indexes :created_at, :type => 'date', :include_in_all => false
  end

  after_save do
    update_index
    update_sticker
  end
  
  serialize :browser_info
  serialize :highrise_cache

  has_many :subscriptions, :as => :owner
  # has_many :active_subscriptions, :as => :owner, :class_name => 'Subscriptions', :conditions => { :active => true }
  # has_many :closed_subscriptions, :as => :owner, :class_name => 'Subscriptions', :conditions => { :active => false }

  has_and_belongs_to_many :smart_lists

  mount_uploader :avatar, AvatarUploader
  mount_uploader :bio_pic, AvatarUploader

  has_many :responses
  
  belongs_to :company 
  has_many :documents, :as => :owner 

  has_many :memberships
  has_many :groups, :through => :memberships

  # has_many :observed_messages, :through => :observer
  # has_many :moderated_messages, :through => :moderator
  
  has_secure_password

  before_save :check_contacts
  before_save :merge_name
  before_save :lowercase_email
  before_create :initialize_person
  before_validation :create_access_token

  attr_accessor :company_name, :send_welcome
  attr_accessible :first_name, :last_name, :email,:company, :company_id, :highrise_id, :password, :password_confirmation, :access_token, :company_name, :send_welcome, :avatar, :avatar_cache, :bio, :bio_pic

  validates_uniqueness_of :email
  
  validates_presence_of :password, :on => :create
  validates_presence_of :access_token
  validates_uniqueness_of :access_token
  
  scope :editors, where(role: 'editors')

  def primary_contact?
    (self.company && self.company.primary_contact == self)
  end

  def billing_contact?
    (self.company && self.company.billing_contact == self)
  end

  def level
    if self.admin?
      'admin'
    elsif self.leadership?
      'leadership'
    elsif self.company_member?
      'company_member'
    elsif self.individual_member?
      'individual_member'
    elsif self.subscriber?
      'subscriber'
    elsif self.pro?
      'pro'
    else
      'basic'
    end
  end

  def committee?
    self.individual_member? || self.company_member? || self.leadership? || self.admin?
  end
  
  def leadership?
    unless self.company.nil?
      self.company.subscriptions.active.pluck(:product).include? 'leadership'
    end               
  end
  
  def company_member?
    unless self.company.nil?
      self.company.subscriptions.active.pluck(:product).include? 'company_member'
    end 
  end

  def individual_member?
    self.subscriptions.active.pluck(:product).include? 'individual_member'
  end

  def subscriber?
    self.subscriptions.active.pluck(:product).include? 'subscriber'
  end

  def pro?
    self.subscriptions.active.pluck(:product).include? 'pro'
  end
  
  def basic?
    self.id.present?
  end

  def super_admin?
    self.role == 'super_admin'
  end
  
  def admin?
    ['admin', 'super_admin'].include? self.role
  end
  
  def editor?
    self.role == 'editor'
  end
  
  def moderator?
    self.role == 'moderator'
  end

  def company?
    self.company.nil?
  end
  
  def title
    if self.highrise_id.present?
      title = Highrise::Person.find(self.highrise_id).title
    end
    title != nil ? title : 'Unknown Title'
  end

  def company_name
    self.company.try(:name) || 'Unknown Company'
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

  def send_mobile_activation
   UserMailer.mobile_activation(self).deliver
  end

  def send_activation
    generate_perishable_token
    self.perishable_token_sent_at = Time.zone.now
    save!
    UserMailer.activation(self).deliver
  end

  def generate_token(column = :auth_token)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while Person.exists?(column => self[column])
  end

  def generate_pin(column = :pin_code)
    begin
      self[column] = format('%04d', rand(9999))
    end while Person.exists?(column => self[column])
  end

  def generate_token!(column = :auth_token)
    generate_token(column)
    self.save!
  end

  def generate_pin!(column = :pin_code)
    generate_pin(column)
    self.save!
  end

  def self.search(params)
    tire.search do
      query { string params[:q], default_operator: "AND" } if params[:q].present?
    end
  end
  
  def update_sticker
    image = Image.new(1000, 240) {
      self.background_color = "#f0f0f0"
    }

    # open("https://s3.amazonaws.com/ccromembers_assets/uploads/mercury/image/image/443/bw_sm_thumb_xx_6277384695_80d0094872_t.jpg", 'rb') do |f|
    #   avatar = Magick::Image::from_blob(f.read)
    # end

    avatar = Magick::Image::from_blob(open(self.avatar.thumb.url).read)[0]
    avatar.resize_to_fit!(200)
    image = image.composite(avatar, Magick::NorthWestGravity, 20, 20, Magick::OverCompositeOp)

    if self.name.present?
      text_name = Draw.new
      text_name.annotate(image, 0,0,240,80, self.name) {
        self.fill = '#0088cc'
        self.pointsize = 18 *4
      }
    end

    if self.company_name.present?
      text_company = Draw.new
      text_company.annotate(image, 0,0,240,38*4, self.company_name) {
        self.fill = 'black'
        self.pointsize = 14 *4
      }
    end

    if self.title != "Unknown Title"
      text_title = Draw.new
      text_title.annotate(image, 0,0,240,54*4, self.title) {
        self.fill = 'black'
        self.pointsize = 14 *4
      }
    end

    image.resize_to_fit!(250)
    image.format = "PNG"
    # image.write("image.png")

    # gotta packet the file
    image.write("#{Rails.root}/tmp/#{self.id}-sticker.gif")

    # upload to Amazon S3
    s3 = AWS::S3.new
    bucket = s3.buckets['ccromembers_assets']
    obj = bucket.objects["person-stickers/" + self.id.to_s + "-sticker.png"]
    obj.write(:file => "#{Rails.root}/tmp/#{self.id}-sticker.gif")
  end

  def sticker_url
    "https://s3.amazonaws.com/ccromembers_assets/person-stickers/#{self.id}-sticker.png"
  end

  private
    
  def initialize_person
    generate_token
    generate_pin
  end

  def check_contacts
    if !self.new_record? && self.company_id_changed? && self.company_id_was && Company.exists?(self.company_id_was)
      previous_company = Company.find(self.company_id_was)
      previous_company.primary_contact = nil if previous_company.primary_contact == self
      previous_company.billing_contact = nil if previous_company.billing_contact == self
      previous_company.save if previous_company.changed?
      true
    else
      true
    end
  end
  
  def merge_name
    self.name = self.first_name + ' ' + self.last_name
  end

  def create_access_token
    self.access_token = rand(36**8).to_s(36) if self.access_token.nil?
  end 
  
  def generate_perishable_token
    begin
      self.perishable_token = SecureRandom.urlsafe_base64
    end while Person.exists?(:perishable_token => self.perishable_token)
  end

  def lowercase_email
    self.email = self.email.downcase
  end

end
