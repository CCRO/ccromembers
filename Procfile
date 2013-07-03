web: bundle exec rails server thin -p $PORT -e $RACK_ENV
worker: RAILS_ENV=production bundle exec rake jobs:work 

