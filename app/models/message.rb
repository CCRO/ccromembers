class Message < ActiveRecord::Base

  acts_as_taggable
  
  has_many :comments, :as => :commentable

  belongs_to :owner, :polymorphic => true
  belongs_to :author, :class_name => 'Person'

  has_many :moderators
  has_many :observers
  is_impressionable
  
  scope :sorted_by_activity, :joins => :comments, :group => 'messages.id', :order => "comments.created_at,messages.created_at DESC"
  scope :archived, where(archived: true)
  scope :not_archived, where(archived: false)
   
  def last_activity_time
    [comments.order(:created_at).last.try(:created_at),self.created_at].compact.first
  end

  def archive
  	self.archived = true
  	self.save
  end

  def unarchive
 	self.archived = false
  	self.save
  end
end
