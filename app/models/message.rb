class Message < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks
  index_name INDEX_NAME
  
  mapping do
    indexes :id,           :index    => :not_analyzed
    indexes :subject,        :analyzer => 'snowball', :boost => 100
    indexes :author,        :as => 'author_name', :analyzer => 'snowball', :boost => 25
    # indexes :file_ext,        :as => 'extension', :analyzer => 'snowball', :boost => 25
    indexes :content,      :analyzer => 'snowball'
    indexes :created_at, :type => 'date', :include_in_all => false
  end

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
   
  def author_name
    self.author.try(:name)
  end

  def self.search(params)
    tire.search do
      query { string params[:q], default_operator: "AND" } if params[:q].present?
      highlight :content
    end
  end

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
