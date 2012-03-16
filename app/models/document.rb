class Document < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
  has_paper_trail
  
  default_scope :order => 'updated_at DESC'
  scope :published, :conditions => { :published => true },
                          :order => 'published_at DESC'
  
end
