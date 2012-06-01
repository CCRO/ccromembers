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
  
  def destroy
    question = Question.find(params[:id])
    survey = question.survey
    
    question.destroy
    
    redirect_to edit_survey_path survey
  end
  
  def new_response
    @question = Question.find(params[:id])
    @response = params[:response_text]
    @index = @question.possible_responses.index(@response)
    if @question.possible_responses
      @question.possible_responses.push(params[:response_text]) if params[:response_text] && params[:response_text] != ""
    else
      @question.possible_responses = [params[:response_text]]
    end
    
    respond_to do |format|
      if @question.save
        format.js { render }
      else
        format.js { render :status => 400, :nothing => true}
      end
    end
    
  end
  
  def destroy_response
    question = Question.find(params[:id])
    
    question.possible_responses.delete_at(params[:response_id].to_i)
    
    question.save
    
    redirect_to edit_survey_path question.survey
  end
     
end
