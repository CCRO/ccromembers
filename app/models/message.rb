class Message < ActiveRecord::Base
  has_many :comments, :as => :commentable
  belongs_to :owner, :polymorphic => true
  belongs_to :author, :class_name => 'Person'
end
