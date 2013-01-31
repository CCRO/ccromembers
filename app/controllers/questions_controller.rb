class QuestionsController < ApplicationController
  
  has_mobile_fu

  def create
    survey = Survey.find(params[:survey_id])
    if survey.questions.empty?
      last_position = 0
    else
      last_position = survey.questions.last.position
    end

    @question = Question.create(params[:question])
    @question.survey = Survey.find(params[:survey_id])
    @question.update_attributes(params[:question])
    @question.position = last_position + 1
    @survey = survey
    
    if @question.save
      render 'create', :locals => {question: @question}
    else
      render status: 400, nothing: true
    end
  end
  
  def show
    @question = Question.find(params[:id])
    @survey = @question.survey

    respond_to do |format|
      format.html
      format.js
    end
  end

  def intro
    @survey = Survey.find(params[:id])

    respond_to do |format|
      format.html
      format.js
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
    
    @question.possible_responses.delete(params[:response_id])

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
      index = (@question.possible_responses.to_a.last[0].to_i + 1).to_s
      @question.possible_responses[index] = params[:response_text]
    else
      @question.possible_responses = {"0" => params[:response_text]}
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

  def update
    @question = Question.find(params[:id])

    respond_to do |format|
      if @question.update_attributes(params[:question])
        format.html { redirect_to edit_survey_path(@question.survey), notice: 'Question was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end
     
end
