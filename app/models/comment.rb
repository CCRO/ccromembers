class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true
  belongs_to :version
  belongs_to :author, :class_name => 'Person'
end
