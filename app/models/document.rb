class Document < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  default_url_options[:host] = 'ccromembers.dev'
  
  belongs_to :owner, :polymorphic => true
  
  has_paper_trail
  
  attr_reader :preview
  
  default_scope :order => 'updated_at DESC'
  scope :published, :conditions => { :published => true },
                          :order => 'published_at DESC'
  def preview
    self.body.split(' ')[0..100].join(' ')
  end
  
  def url
    document_url(self)
  end
  
  def to_xml(options={})
    options.merge!(:except => [:body, :created_at, :updated_at], :include => [:owner], :methods => [:preview, :url])
    super(options)
  end
  
  def as_json(options={})
    options.merge!(:except => [:body, :created_at, :updated_at], :include => [:owner], :methods => [:preview, :url])
    super(options)
  end
  
  def to_param
    permalink
  end

  def permalink
    "#{id}-#{title.parameterize}"
  end
  
end
