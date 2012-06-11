class Question < ActiveRecord::Base
  belongs_to :survey
  has_many :responses
  
  serialize :possible_responses
  
  def results
    case self.response_type
    when 'radio'
      self.possible_responses.zip(self.possible_responses.map { |r| Response.where(question_id: self.id, selected_response: self.possible_responses.index(r)).count })
    when 'checkbox'
      self.possible_responses.zip(self.responses.pluck(:selected_responses).transpose.map {|x| x.reduce(:+)})
    end
  end
end
