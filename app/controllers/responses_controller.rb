class ResponsesController < ApplicationController
  
  def new
    @response = Response.new
  end
  
 
  def create
    @response = Response.new(params[:response])
    @response.question_id = params[:question_id]
    @response.person_id = current_user.id if current_user
    @response.company_id = current_user.company.id if current_user && current_user.company
    
    if @response.question.survey.company_survey == true
      old = Response.where(question_id: @response.question.id, company_id: current_user.company.id)
      old.each {|r| r.destroy; }
    else
      old = Response.where(question_id: @response.question.id, person_id: current_user.id)
      old.each {|r| r.destroy; }
    end

    if @response.question.response_type == 'checkbox'
      selected_responses = Array.new
      @response.question.possible_responses.count.times { selected_responses.push(0) }
      if params[:checked_responses]
        params[:checked_responses].each do |checked_item,val|
          selected_responses[checked_item.to_i] = 1
        end
      end
      logger.info "Checked Form Items: " + params[:checked_responses].to_s
      logger.info "Responses: " + selected_responses.to_s
      @response.selected_responses = selected_responses
    end
    
    
    respond_to do |format|
      if @response.person_id.present? && @response.save!
        logger.info "Response: " + @response.to_json.to_s
        format.html { redirect_to @response.question.survey, :flash => { :success => 'Response was successfully created.'} }
        format.js { render status: 200, nothing: true }
      else
        format.html { redirect_to :back }
        format.js { render nothing: true }
      end
    end
    
  end

  def update
    @response = Response.find(params[:id])
    @response.question_id = params[:question_id]
    @response.person_id = current_user.id if current_user
    @response.company_id = current_user.company.id if current_user && current_user.company?
    @response.update_attributes(params[:response])
    
    if @response.question.response_type == 'checkbox'
      selected_responses = Array.new
      @response.question.possible_responses.count.times { selected_responses.push(0) }
      if params[:checked_responses]
        params[:checked_responses].each do |checked_item,val|
          selected_responses[checked_item.to_i] = 1
        end
      end
      logger.info "Responses: " + selected_responses.to_s
      @response.selected_responses = selected_responses
    end

    respond_to do |format|
      if@response.person_id.present? && @response.save
        format.html { redirect_to @response.question.survey, :flash => { :success => 'Response was successfully created.'} }
        format.js { render status: 200, nothing: true }
      else
        format.html { redirect_to :back }
        format.js { render nothing: true }
      end
    end
  end
end
