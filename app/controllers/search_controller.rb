class SearchController < ApplicationController

  def index
    if params[:q]
      @person_results = Person.search(params)
      @attachment_results = Attachment.search(params)
      @message_results = Message.search(params)
      @post_results = Post.where(:published => true).search(params)
    end
  end
end
