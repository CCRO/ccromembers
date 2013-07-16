class Post < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks
  index_name INDEX_NAME

  mapping do
    indexes :id,           :index    => :not_analyzed
    indexes :title,        :analyzer => 'snowball', :boost => 100
    indexes :author,        :as => 'author_name', :analyzer => 'snowball', :boost => 25
    # indexes :file_ext,        :as => 'extension', :analyzer => 'snowball', :boost => 25
    indexes :body,      :analyzer => 'snowball'
    indexes :created_at, :type => 'date', :include_in_all => false
  end
  
  has_paper_trail
  acts_as_taggable
  
  include ActionView::Helpers::SanitizeHelper
  
  belongs_to :author, :class_name => 'Person'
  belongs_to :owner, :polymorphic => true
  belongs_to :locker, :class_name => 'Person'
  has_many :comments, :as => :commentable
  is_impressionable

 
  before_save :set_published_date
  
  validate :title, :presence => true
  
  def to_param
    permalink
  end

  def author_name
    self.author.try(:name)
  end

  def generate_token(column = :viewing_token)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while Post.exists?(column => self[column])
  end

  def lock(person)
    self.locked = true
    self.locker = person
    self.locked_at = Time.now
  end

  def unlock
    self.locked, self.locked_at = nil, nil
  end

  def self.search(params)
    tire.search do
      query { string params[:q], default_operator: "AND" } if params[:q].present?
      highlight :body
    end
  end

  def share_by_email(email_list, my_subject, short_message, sender)
    if email_list.class.name == 'String'
      email_list = email_list.gsub(' ', '').split(',')
      email_list.each do |email|
        PostMailer.delay.share_post(self, email, my_subject, short_message, sender)
      end
    elsif email_list.class.name == 'Array'
      email_list.each do |person|
        PostMailer.delay.share_post(self, person.email, my_subject, short_message, sender)
      end
    end
  end


  def submit_by_email(email_list, sender)
    email_list.each do |person|
      PostMailer.submit_post(self, person.email, sender).deliver
    end
  end



  def locked?
    if self.locked_at && self.locked_at < 2.hours.ago
      self.unlock
      self.save
    end
    self.locked
  end

  def permalink
    "#{id}-#{strip_tags(title).strip.parameterize}"
  end
  
  private 
  
  def set_published_date
    self.published_at ||= Time.now if self.published == true
    true
  end
end
