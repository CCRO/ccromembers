class PostMailer < ActionMailer::Base
  default from: "info@ccro.org"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.post_mailer.share_post.subject
  #
  def share_post(post, email, sender)
    @post = post
    @sender = sender
    @email = email
    mail :to => @email, :subject => "#{@sender.name} has shared a CCRO article with you titled \"#{@post.title}\""
  end
end
