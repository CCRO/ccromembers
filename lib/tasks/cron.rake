desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  if Time.now.hour % 4 == 0 # run every four hours

  end

  if Time.now.hour == 0 # run at midnight
    
  end
  
  #run every time cron is called.
  puts "Updating company balances..."
  Company.all.each do |company|
    company.update_balance!
  end
  puts "done."
  
end