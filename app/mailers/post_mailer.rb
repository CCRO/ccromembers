class PostMailer < ActionMailer::Base
  default from: "info@ccro.org"
  include ActionView::Helpers::SanitizeHelper
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.post_mailer.share_post.subject
  #
  def share_post(post, email, my_subject, short_message, sender)
    @post = post
    @sender = sender
    @short_message = short_message
    mail(:to => email, :from => sender.email, :subject => my_subject)
  end

  def submit_post(post, email, sender)
    @post = post
    @sender = sender
    mail(:to => email, :from => sender.email, :subject => "#{sender.name} is submitting a post for publication.")
  end
end
