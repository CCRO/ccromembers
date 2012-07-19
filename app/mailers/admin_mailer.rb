class AdminMailer < ActionMailer::Base
  default from: "info@ccro.org"

  def signup_complete(person, requested_url)
    @person = person
    @requested_url = requested_url
    mail :to => 'admin@ccro.org', :subject => "There was a new signup on the CCRO Website!"
  end
end
