class Response < ActiveRecord::Base
  belongs_to :person
  belongs_to :company
  belongs_to :question
  
  serialize :selected_responses
  
  #validates_uniqueness_of :person_id, scope: [:question_id]
  
end
