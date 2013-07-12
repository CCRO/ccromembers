class PageMailer < ActionMailer::Base
  default from: "info@ccro.org"
  include ActionView::Helpers::SanitizeHelper
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.post_mailer.share_page.subject
  #
  def share_page(page, email, my_subject, short_message, sender)
    @page = page
    @sender = sender
    @short_message = short_message
    mail(:to => email, :from => sender.email, :subject => my_subject)
  end
end
