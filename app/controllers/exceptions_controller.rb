class ExceptionsController < ApplicationController

  has_mobile_fu

  def accessdenied
  	cookies[:url_after_signup] = session[:url_return_to]

    respond_to do |format|
      format.mobile {render :layout => '/layouts/blank.html.erb'}
      format.html
    end
  end
end
