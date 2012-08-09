class Message < ActiveRecord::Base
  has_many :comments, :as => :commentable

  belongs_to :owner, :polymorphic => true
  belongs_to :author, :class_name => 'Person'

  is_impressionable
  
  scope :sorted_by_activity, :joins => :comments, :group => 'messages.id', :order => "comments.created_at,messages.created_at DESC"
   
  def last_activity_time
    [comments.order(:created_at).last.try(:created_at),self.created_at].compact.first
  end
end
