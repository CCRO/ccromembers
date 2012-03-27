class Document < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  default_url_options[:host] = 'ccromembers.dev'
  
  belongs_to :owner, :polymorphic => true
  has_many :comments, :as => :commentable
  
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
      wikitext = Wiky::Wikitext.new(CCROHTML)
      html_body = wikitext.process(self.body).html_safe
    else
      html_body = self.body.html_safe
    end
    
    body = Nokogiri::HTML(html_body)
    @sections = body.xpath('//body').children.inject([]) do |sections_hash, child|
      if child.name == 'h2' || child.name == 'h3'
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
  
end
