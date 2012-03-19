if Rails.evn.production?
  ActionMailer::Base.smtp_settings = {
    :address        => 'smtp.sendgrid.net',
    :port           => '587',
    :authentication => :plain,
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => 'ccro.org'
  }
  ActionMailer::Base.delivery_method = :smtp
else
  ActionMailer::Base.smtp_settings = {
    :address              => "localhost",
    :port                 => 1025,
    :domain               => "ccro.org",
  }
end

ActionMailer::Base.default_url_options[:host] = 'localhost:3000'
  