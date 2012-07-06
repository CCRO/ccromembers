class Post < ActiveRecord::Base
  
  has_paper_trail
  acts_as_taggable
  
  include ActionView::Helpers::SanitizeHelper
  
  belongs_to :author, :class_name => 'Person'
  belongs_to :owner, :polymorphic => true

  belongs_to :locker, :class_name => 'Person'
 
  has_many :comments, :as => :commentable
 
  before_save :set_published_date
  
  validate :title, :presence => true
  
  def to_param
    permalink
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
    self.locked, self.locker, self.locked_at = nil, nil, nil
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
