module SurveysHelper
  def first_unanswered_question(survey)
    survey.questions.each do |q|
      if q.responses.where(person_id: current_user).empty?
        return q
      end
    end
    return survey.questions.first
  end

  def response_count(survey)
    list_of_people = []

    survey.questions.each do |q|
      q.responses.each do |r|
        list_of_people << r.person_id
      end
    end

    return list_of_people.uniq.count
  end
end
