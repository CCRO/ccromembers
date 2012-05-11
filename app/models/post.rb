class Post < ActiveRecord::Base
  belongs_to :author, :class_name => 'Person'
  belongs_to :owner, :polymorphic => true
  
  default_scope :order => 'created_at DESC'
  
  before_save :set_published_date
  
  private 
  
  def set_published_date
    self.published_at == Time.now if self.published_changed?
  end
end
