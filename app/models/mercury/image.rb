class Mercury::Image < ActiveRecord::Base


  mount_uploader :image, ImageUploader

  delegate :url, :to => :image

  def serializable_hash(options = nil)
    options ||= {}
    options[:methods] ||= []
    options[:methods] << :url
    super(options)
  end

end
