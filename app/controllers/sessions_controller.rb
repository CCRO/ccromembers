class SessionsController < ApplicationController
  before_filter :require_no_user, :only => ['new', 'create']
  before_filter :require_user, :only => 'destroy'
  def new
  end
  
  def create
    user = Person.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_back_or_default root_url
    else
      flash.now.alert = t(:login_invalid)
      render "new"
    end
  end
  
  def destroy
    session[:user_id] = nil
    redirect_to root_url, :flash => {:success => t(:logout_flash)}
  end
end
