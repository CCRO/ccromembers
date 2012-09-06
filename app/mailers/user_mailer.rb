class UserMailer < ActionMailer::Base
  default from: "info@ccro.org"

  def password_reset(person)
    @person = person
    mail :to => person.email, :subject => "Password Reset"
  end
  
  def password_reset_success(person)
    @person = person
    mail :to => person.email, :subject => "Password Reset Successfully"
  end

  def activation(person)
    @person = person
    mail :to => person.email, :subject => "Please activate your CCRO account"
  end

  def mobile_activation(person)
    @person = person
    mail :to => person.email, :subject => "Please link your mobile phone to your CCRO account"
  end
  
end