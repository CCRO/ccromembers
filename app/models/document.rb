class Document < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  default_url_options[:host] = 'ccromembers.dev'
  
  belongs_to :author, :class_name => 'Person'
  belongs_to :owner, :polymorphic => true
  has_many :comments, :as => :commentable
  
  is_impressionable
  has_paper_trail
  
  attr_reader :preview
  
  default_scope :order => 'updated_at DESC'
  scope :published, :conditions => { :published => true },
                          :order => 'published_at DESC'

  before_save :update_viewer_uuid

  def preview
    self.body.split(' ')[0..100].join(' ')
  end
  
  def url
    document_url(self)
  end
  
  def author
    self.owner.name
  end
  
  def sections
    case self.format
    when "markdown"
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML,
              :autolink => true, :space_after_headers => true)
      html_body = markdown.render(self.body).html_safe
    when "wikitext"
      wikitext = Wiky::Wikitext.new()
      html_body = wikitext.process(self.body).html_safe
    else
      html_body = self.body.html_safe
    end
    
    body = Nokogiri::HTML(html_body)
    @sections = body.xpath('//body').children.inject([]) do |sections_hash, child|
      if child.name == 'h2'
        title = child.inner_text
        sections_hash << { :title => title, :contents => ''}
      end

      next sections_hash if sections_hash.empty?
      sections_hash.last[:contents] << child.to_xhtml
      sections_hash
    end
  end
  
  def to_xml(options={})
    options.merge!(:except => [:body, :created_at, :updated_at], :methods => [:preview, :url, :author])
    super(options)
  end
  
  def as_json(options={})
    options.merge!(:except => [:body, :created_at, :updated_at], :methods => [:preview, :url, :author])
    super(options)
  end
  
  def to_param
    permalink
  end

  def permalink
    "#{id}-#{title.parameterize}"
  end

  def update_viewer_uuid
    if self.viewer_uuid_updated_at.blank? || self.viewer_uuid_updated_at < self.updated_at
      begin
        logger.info "PDF URL: " + document_url(self, :format => 'pdf')
        uuid = Crocodoc::Document.upload(document_url(self, :format => 'pdf'))
        self.viewer_uuid = uuid
        self.viewer_uuid_updated_at = Time.now
      rescue CrocodocError => e
        puts 'failed :('
        puts '  Error Code: ' + e.code
        puts '  Error Message: ' + e.message
      end
      logger.info "UUID: " + uuid
    end
  end

  def update_viewer_uuid!
    self.update_viewer_uuid
    self.save
  end

  def generate_token(column = :viewing_token)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while Post.exists?(column => self[column])
  end
 
end
