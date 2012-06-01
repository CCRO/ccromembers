class Response < ActiveRecord::Base
  belongs_to :person
  belongs_to :question
  
  serialize :selected_responses
  
end
