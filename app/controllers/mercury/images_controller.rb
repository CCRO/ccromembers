class Mercury::ImagesController < MercuryController
  
  respond_to :json

  def create
     @blog_image = ActiveRecord::Base::Image.new(params[:image])
     @blog_image.save!
     render :json => @blog_image.to_json(:only => :image)
  end

  def destroy
    @image = ActiveRecord::Base::Image.find(params[:id])
    @image.destroy
    respond_with @image
  end

end
