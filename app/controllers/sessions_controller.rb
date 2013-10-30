class SessionsController < ApplicationController
  
  layout 'blank'
  has_mobile_fu
  
  before_filter :require_no_user, :only => ['new', 'create']
  before_filter :require_user, :only => 'destroy'

  def new
    respond_to do |format|
      format.mobile {render :layout => '/layouts/blank.html.erb'}
      format.tablet {render :layout => '/layouts/blank.html.erb'}
      format.html
    end
  end
  
  def create
    if params[:email]
      email = params[:email]
      email = email.downcase
    end
     
    user = Person.find_by_email(email)
    if user && user.verified && user.authenticate(params[:password])
      if params[:remember_me]
        cookies.permanent.signed[:auth_token] = user.auth_token
      end
      session[:user_id] = user.id
      session[:warning_closed] = false
      # user.browser_info = {name: browser.name, platform: browser.platform.to_s}
      user.save
      redirect_back_or_default root_url
    else
      flash.now.alert = t(:login_invalid)
      render "new"
    end
  end
  
  def activation
  end

  def activate
    if cookies[:url_after_signup]
      redirect_to cookies[:url_after_signup] if current_user
    else
      redirect_to current_user if current_user 
    end
  end
  
  def destroy
    cookies.delete(:auth_token)
    session[:user_id] = nil
    redirect_back_or_default root_url, :flash => {:success => t(:logout_flash)}
  end

  def warning_closed
    session[:warning_closed] = true
    redirect_to :back
  end
end
