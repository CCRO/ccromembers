class Survey < ActiveRecord::Base

  has_many :questions, :dependent => :destroy, order: "position"
  
  belongs_to :author, :polymorphic => true
  belongs_to :owner, :class_name => 'Person'
  
  default_scope :order => 'created_at'
  is_impressionable
  
  before_save :set_published_date
  
  validates_presence_of :title
  

  
  private 
  
  def set_published_date
    self.published_at = Time.now if self.published_changed?
    true
  end


  
end
