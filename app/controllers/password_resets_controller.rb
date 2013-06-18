class PasswordResetsController < ApplicationController
  
  layout 'blank'
  has_mobile_fu
  
  def new
    respond_to do |format|
      format.mobile {render :layout => '/layouts/blank.html.erb'}
      format.tablet {render :layout => '/layouts/blank.html.erb'}
      format.html
    end
  end
  
  def edit
    unless @person = Person.find_by_perishable_token(params[:perishable_token])
      redirect_to forgot_password_path, :flash => {:error => "Password reset token not found."}
    end
    
    respond_to do |format|
      format.mobile {render :layout => '/layouts/blank.html.erb'}
      format.tablet {render :layout => '/layouts/blank.html.erb'}
      format.html
    end
  end
  
  def create
    person = Person.find_by_email(params[:email])
    person.send_password_reset if person
    redirect_to forgot_password_path, :flash => {:info => "Email sent with password reset instructions."}
  end
  
  def update
    @person = Person.find_by_perishable_token!(params[:perishable_token])
    if @person.perishable_token_sent_at < 2.hours.ago
      redirect_to forgot_password_path, :alert => "Password reset has expired."
    elsif @person.update_attributes(params[:person])
      UserMailer.password_reset_success(@person).deliver
      session[:user_id] = @person.id
      redirect_to dashboard_path, :flash => {:success => "Password has been reset."}
    else
      render :edit
    end
  end
  
end
