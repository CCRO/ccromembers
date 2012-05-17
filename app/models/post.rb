class Post < ActiveRecord::Base
  belongs_to :author, :polymorphic => true
  belongs_to :owner, :class_name => 'Person'
  
  default_scope :order => 'created_at DESC'
  
  before_save :set_published_date
  
  validates_presence_of :title
  
  private 
  
  def set_published_date
    self.published_at = Time.now if self.published_changed?
    true
  end
end
