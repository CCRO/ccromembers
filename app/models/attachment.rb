class Attachment < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks
  
  belongs_to :owner, :polymorphic => true
  belongs_to :author, :class_name => 'Person'

  mount_uploader :file, FileUploader

  before_save :update_asset_attributes
  
  after_save do
    update_index
  end

  mapping do
    indexes :id,           :index    => :not_analyzed
    indexes :uuid,           :index    => :not_analyzed
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
      self.content = Crocodoc::Download.text(uuid)
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

  private

  def update_asset_attributes
    if file.present? && file_changed?
      self.content_type = file.file.content_type
      self.file_size = file.file.size
    end
  end
end
