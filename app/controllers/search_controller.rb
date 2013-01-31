class SearchController < ApplicationController

  def index
    @person_results = Person.search(params)
    @attachment_results = Attachment.search(params)
  end
end
