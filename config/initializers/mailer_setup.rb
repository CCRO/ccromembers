if Rails.env.production?
  ActionMailer::Base.smtp_settings = {
    :address        => ENV['SMTP_HOST'],
    :port           => '587',
    :authentication => :plain,
    :user_name      => ENV['SMTP_USERNAME'],
    :password       => ENV['SMTP_PASSWORD'],
    :domain         => 'heroku.com'
  }
  ActionMailer::Base.delivery_method = :smtp
else
  ActionMailer::Base.smtp_settings = {
    :address              => "localhost",
    :port                 => 1025,
    :domain               => "ccro.org",
  }
end

if false
ActionMailer::Base.default_url_options[:host] = 'localhost:3000'
else
ActionMailer::Base.default_url_options[:host] = 'localhost'
end
