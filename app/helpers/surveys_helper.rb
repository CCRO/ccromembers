module SurveysHelper
    def first_unanswered_question(survey)
      survey.questions.each do |q|
        if q.responses.where(person_id: current_user).empty?
          return q
        end
      end
    end
end
