class UserMailer < ActionMailer::Base
  default from: "CCRO_Resources@ccro.org"

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

  #######

  def request_company(person, company_name, survey)
    @person = person
    @company_name = company_name
    @survey = survey

    mail :to => 'joeylapetina@gmail.com', :subject => "Verify <%= @person.name %> to <%= company_name %>"
  end

  def suggest_primary(person, first, last, email)
    @person = person
    @first = first
    @last = last
    @email = email

    mail :to => 'joeylapetina@gmail.com', :subject => "<%= @person.company.name %> needs primary contact <%= @person.name %> suggests <%= #{first} #{last}: #{email}%>"
  end

  def request_survey_access(person, survey)
    @person = person
    @survey = survey

    mail :to => 'joeylapetina@gmail.com', :subject => "<%= @person.name %> is requesting to access  the CCRO survey '<%= survey.title %>' on behalf <%= @person.company.name %>."
  end

  def access_granted(person, survey) #self should have not been set to current_user but the person granted access
    @person = person
    @survey = survey

    mail :to => 'joeylapetina@gmail.com', :subject => "You have been given access to the CCRO survey of #{@person.company.name} titled '#{@survey.title}' by #{@person.company.primary_person.name}."
  end

  def access_revoked(person, survey) #self should have not been set to current_user but the person revoked access
    @person = person
    @survey = survey

    mail :to => 'joeylapetina@gmail.com', :subject => "Your access to the CCRO survey of #{@person.company.name} titled '#{@survey.title}' has ended."
  end

  def invite_user(person, first, last, email)
    @person = person
    @first = first
    @last = last
    @email = email

    mail :to => 'joeylapetina@gmail.com', :subject => "Verify <%= @person.name %> to <%= company_name %>"
  end
  
end



































