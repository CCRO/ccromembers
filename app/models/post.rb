class Post < ActiveRecord::Base
  belongs_to :author, :class_name => 'Person'
  belongs_to :owner, :polymorphic => true
  
  default_scope :order => 'created_at DESC'
  
end
