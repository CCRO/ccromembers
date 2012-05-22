class QuestionsController < ApplicationController
  def create
    @question = Question.create(params[:question])
    @question.survey = Survey.find(params[:survey_id])
    if @question.save
      redirect_to edit_survey_path(@question.survey)
    else
      render 'new'
    end
  end
end
