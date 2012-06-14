class Question < ActiveRecord::Base
  belongs_to :survey
  has_many :responses
  
  serialize :possible_responses
  
  acts_as_list scope: :survey
  
  def results
    if (((self.response_type == 'radio' || self.response_type == 'checkbox') && self.possible_responses.present?) || (self.response_type == 'singleline' || self.response_type == 'multiline')) && self.responses.present?
      case self.response_type
      when 'radio'
        self.possible_responses.zip(self.possible_responses.map { |r| Response.where(question_id: self.id, selected_response: self.possible_responses.index(r)).count })
      when 'checkbox'
        self.possible_responses.zip(self.responses.pluck(:selected_responses).transpose.map {|x| x.reduce(:+)})
      when 'singleline', 'multiline'
        ignored_words = ["the", "of", "this", "it", "is", "by", "a", "for", "when", "how", "and", "in", "from"]
        (self.responses.pluck(:text_response).compact.map { |r| r.downcase.gsub(/[^a-z ]/, '').split(" ") }.flatten - ignored_words).reduce(Hash.new(0)) { |total, e| total[e] += 1; total }.delete_if { |key, value| value <= 1 || key.length < 3}.sort_by {|key, value| value}.reverse
      end
    else
      nil
    end
  end
end
