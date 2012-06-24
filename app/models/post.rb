class Post < ActiveRecord::Base
  
  include ActionView::Helpers::SanitizeHelper
  
  belongs_to :author, :class_name => 'Person'
  belongs_to :owner, :polymorphic => true
  
  default_scope :order => 'created_at DESC'
  
  before_save :set_published_date
  
  validate :title, :presence => true
  
  def to_param
    permalink
  end

  def permalink
    "#{id}-#{strip_tags(title).strip.parameterize}"
  end
  
  private 
  
  def set_published_date
    self.published_at = Time.now if self.published_changed?
    true
  end
end
