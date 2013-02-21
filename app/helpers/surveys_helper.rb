module SurveysHelper
  def first_unanswered_question(survey)
    survey.questions.each do |q|
      if q.responses.where(person_id: current_user).empty?
        return q
      end
    end
    return survey.questions.first
  end

  def survey_respondents(survey)
    temp = []
    list_of_people = []

    unless survey.questions.empty?
      survey.questions.each do |q|
        unless  q.responses.empty?
          q.responses.each do |r|
            temp << r.person_id
          end
        end
      end
    end

    unless temp.empty?
      temp.each do |i|
        unless Person.find(i).admin?
          list_of_people << Person.find(i)
        end
      end
    end

    return list_of_people.uniq || nil
  end

  def radio_question_responses(question, response)
    temp = []
    response_people = []
    temp = Response.where(question_id: question, selected_response: response).to_a

    temp.each do |t|
      unless Person.find(t.person_id).admin?
        response_people << Person.find(t.person_id)
      end
    end
    
    return response_people
  end 

  def checkbox_question_responses(question, key)
    temp = []
    response_people = []
    all_responses = []
    temp = Response.where(question_id: question)

    temp.each do |t|
      unless Person.find(t.person_id).admin?
        all_responses << t
      end
    end
    
    unless all_responses.empty?
      all_responses.each do |r|
        unless r.selected_responses.nil?
          if r.selected_responses[key.to_i] == 1
            response_people << Person.find(r.person_id)
          end
        end
      end
    end

    return response_people
  end
end




















