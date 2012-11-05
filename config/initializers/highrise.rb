if Rails.env != 'test' then
  Highrise::Base.site = ENV['HIGHRISE_URL']
  Highrise::Base.user = ENV['HIGHRISE_TOKEN']
  Highrise::Base.format = :xml
end