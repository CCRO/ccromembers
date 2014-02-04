class Response < ActiveRecord::Base
  belongs_to :person
  belongs_to :company
  belongs_to :question
  
  serialize :selected_responses
  
  #validates_uniqueness_of :person_id, scope: [:question_id]
  def self.as_csv
    CSV.generate do |csv|
      csv << ["Survey", "Company", "Person", "Prompt", "Response"]
      all.each do |item|
        csv << [item.question.survey.title, item.person.company.name, item.person.name, item.question.prompt, item.summary]
      end
    end
  end

  def summary
    if question.present?
      if selected_responses
        answer = Array.new
        self.selected_responses.each_with_index do |val, key| 
          if val == 1
            answer << self.question.possible_responses["#{key}"]
          end
        end
      elsif text_response
        answer = self.text_response
      else
        answer = self.question.possible_responses["#{selected_response}"]
      end
      return answer
    end
  end
  
end
