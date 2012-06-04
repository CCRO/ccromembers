class QuestionsController < ApplicationController
  def create
    @question = Question.create(params[:question])
    @question.survey = Survey.find(params[:survey_id])
    @question.update_attributes(params[:question])
    
    if @question.save
      render 'create', :locals => {question: @question}
    else
      render status: 400, nothing: true
    end
  end
  
  def destroy
    @question = Question.find(params[:id])
    survey = @question.survey
    
    respond_to do |format|
      if @question.destroy
        format.js { render }
      else
        format.js { render :status => 400, :nothing => true}
      end
    end
    
    #redirect_to edit_survey_path survey
  end
  
  def destroy_response
    @question = Question.find(params[:id])
    
    @question.possible_responses.delete_at(params[:response_id].to_i)
    
    @question.save
    
    @response_id = params[:response_id].to_i
    
    respond_to do |format|
      if @question.save
        format.js { render }
      else
        format.js { render :status => 400, :nothing => true}
      end
    end
  end
  
  def new_response
    @question = Question.find(params[:id])
    @response = params[:response_text]
    
    if @question.possible_responses
      @question.possible_responses.push(params[:response_text]) if params[:response_text] && params[:response_text] != ""
    else
      @question.possible_responses = [params[:response_text]]
    end
    
    @index = @question.possible_responses.index(@response)
    
    respond_to do |format|
      if @question.save
        format.js { render }
      else
        format.js { render :status => 400, :nothing => true}
      end
    end
    
  end
     
end
