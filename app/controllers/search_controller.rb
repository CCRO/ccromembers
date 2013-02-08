class SearchController < ApplicationController

  def index
    @person_results = Person.search(params)
    @attachment_results = Attachment.search(params)
    @message_results = Message.search(params)
    @post_results = Post.where(:published => true).search(params)
  end
end
