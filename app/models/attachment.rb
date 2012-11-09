class Attachment < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
  belongs_to :author, :class_name => 'Person'

  mount_uploader :file, FileUploader

  before_save :update_asset_attributes
  
  default_scope order('created_at DESC')
  
  def get_crocodoc_uuid
    begin
      logger.info "Crocodoc Token: " + ENV['CROCODOC_API_TOKEN']
      logger.info "PDF URL: " + self.file.url
      uuid = Crocodoc::Document.upload(self.file.url)
      self.crocodoc_uuid = uuid
   rescue CrocodocError => e
      puts 'failed :('
      puts '  Error Code: ' + e.code
      puts '  Error Message: ' + e.message
    end
    # logger.info "UUID: " + uuid
  end

  def extension
    self.file.file.url.split(".").last
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
