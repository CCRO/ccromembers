class Subscription < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
  scope :active, where(:active => true)
  scope :closed, where(:active => false)
  
end
