module SurveysHelper
  def first_unanswered_question(survey)
    survey.questions.each do |q|
      if q.responses.where(person_id: current_user).empty?
        return q
      end
    end
    return survey.questions.first
  end

  def respondents(survey)
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
end
