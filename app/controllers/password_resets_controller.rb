class PasswordResetsController < ApplicationController

  def new
  end
  
  def edit
    @person = Person.find_by_perishable_token!(params[:perishable_token])
  end
  
  def create
    person = Person.find_by_email(params[:email])
    person.send_password_reset if person
    redirect_to forgot_password_path, :flash => {:info => "Email sent with password reset instructions."}
  end
  
  def update
    @person = Person.find_by_perishable_token!(params[:perishable_token])
    if @person.perishable_token_sent_at < 2.hours.ago
      redirect_to forgot_password_path, :alert => "Password &crarr; 
        reset has expired."
    elsif @person.update_attributes(params[:person])
      UserMailer.password_reset_success(@person).deliver
      redirect_to root_path, :flash => {:success => "Password has been reset."}
    else
      render :edit
    end
  end
  
end
