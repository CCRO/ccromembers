class ExceptionsController < ApplicationController
  def accessdenied
  	cookies[:url_after_signup] = session[:url_return_to]
  end
end
