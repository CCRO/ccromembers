class Attachment < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks
  
  acts_as_taggable

  belongs_to :owner, :polymorphic => true
  belongs_to :author, :class_name => 'Person'

  mount_uploader :file, FileUploader
  mount_uploader :thumbnail, FileUploader

  serialize :options, OpenStruct
  serialize :crocodoc_uuids, Array

  before_save :update_asset_attributes
  
  after_save do
    update_index
  end

  mapping do
    indexes :id,           :index    => :not_analyzed
    indexes :crocodoc_uuid,           :index    => :not_analyzed
    indexes :title,        :analyzer => 'snowball', :boost => 100
    indexes :description,      :analyzer => 'snowball', :boost => 50
    indexes :author,        :as => 'author_name', :analyzer => 'snowball', :boost => 25
    # indexes :file_ext,        :as => 'extension', :analyzer => 'snowball', :boost => 25
    indexes :content,      :analyzer => 'snowball'
    indexes :created_at, :type => 'date', :include_in_all => false
  end

   default_scope order('created_at DESC')
  
  def get_crocodoc_uuid
    begin
      uuid = Crocodoc::Document.upload(self.file.url)
      self.crocodoc_uuid = uuid
   rescue CrocodocError => e
      puts 'failed :('
      puts '  Error Code: ' + e.code
      puts '  Error Message: ' + e.message
    end
  end

  def author_name
    self.author.try(:name)
  end

  def extension
    self.file.file.url.split(".").last if self.file
  end

  def get_crocodoc_uuid!
    self.get_crocodoc_uuid
    self.save
  end

  def downloadable?
    options.downloadable == "1"
  end

  def download_text
    self.content = Crocodoc::Download.text(self.crocodoc_uuid)
    self
  end

  def download_text!
    self.download_text
    self.save
  end

  def download_thumbnail
    io = FilelessIO.new(Crocodoc::Download.thumbnail(self.crocodoc_uuid))
    io.original_filename = self.crocodoc_uuid + "_thumbnail.png"

    self.thumbnail = io
    self
  end

  def download_thumbnail!
    self.download_thumbnail
    self.save
  end

  def crocodoc_getstatus
    status = Crocodoc::Document.status(self.crocodoc_uuid)
    self.crocodoc_status = status['status']
    self.crocodoc_viewable = status['viewable']
    self
  end

  def crocodoc_getstatus!
    self.crocodoc_getstatus.save
  end

  def commentable?
    options.commentable == "1"
  end
  
  def self.search(params)
    tire.search do
      query { string params[:q], default_operator: "AND" } if params[:q].present?
      highlight :description, :content
    end
  end

  private

  def update_asset_attributes
    if file.present? && file_changed?
      self.crocodoc_uuids << self.crocodoc_uuid
      self.get_crocodoc_uuid
      self.content_type = file.file.content_type
      self.file_size = file.file.size
    end

    if self.crocodoc_uuid.present?
      self.crocodoc_getstatus
      self.download_text
      self.download_thumbnail
    end
  end
end
