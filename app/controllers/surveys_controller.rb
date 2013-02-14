class SurveysController < ApplicationController
  
  
  layout 'survey', :except => :intro
  before_filter :require_user
  has_mobile_fu
  
  
  def index
    @surveys = Survey.all

    respond_to do |format|
      format.mobile {render :layout => '/layouts/blank.html.erb'}
      format.html
      format.js
    end
  end

  def show
    @survey = Survey.find(params[:id])
    @response = Response.new
    
    authorize! :read, @survey
  end

  def intro
    @survey = Survey.find(params[:id])
  end

  def slide_show
    @survey = Survey.find(params[:id])

    redirect_to survey_question_path(@survey, @survey.questions.first)
  end

  def new
    @survey = Survey.new
    authorize! :create, @survey
  end

  def create
    @survey = Survey.new(params[:survey])
    
    authorize! :create, Survey

    @survey.author = current_user
    
    if @survey.save
      redirect_to surveys_path
    else
      flash[:notice] = "Please give your new survey a title."
      redirect_to surveys_path
    end
  end

  def edit
    @survey = Survey.find(params[:id])
    authorize! :edit, @survey
  end
  
  def sort
    params[:question].each_with_index do |id, index|
      Question.update_all({position: index+1}, {id: id})
    end
    render nothing: true
    
  end
  
  def update
    @survey = Survey.find(params[:id])
    authorize! :edit, @survey
    @survey.update_attributes(params[:survey])
  end

  def destroy
    @survey = Survey.find(params[:id])
    
    authorize! :destroy, @survey

    @survey.destroy
    
    redirect_to surveys_path
  end

  def report
    @survey = Survey.find(params[:id])
    authorize! :create, @survey

    if false
      @chart = Array.new
      @cloud = Array.new

      authorize! :create, @survey
      
      @survey.questions.each do |q|
        if q.results.present?
          if q.response_type == 'radio' || q.response_type == 'checkbox' || q.response_type == 'multiline' || q.response_type == 'singleline' 
            data_table = GoogleVisualr::DataTable.new

            # Add Column Headers 
            data_table.new_column('string', 'Prompt' ) 
            data_table.new_column('number', 'Responses') 

            # Add Rows and Values 
            data_table.add_rows(q.results[0].to_i)
      
            option = { width: 800, height: 480, title: q.prompt, :is3D => true }
          end
          case q.response_type
          when 'radio'
            @chart.push(GoogleVisualr::Interactive::PieChart.new(data_table, option))
          when 'checkbox'
            @chart.push(GoogleVisualr::Interactive::BarChart.new(data_table, option))
          when 'singleline', 'multiline'
            @chart.push(GoogleVisualr::Interactive::PieChart.new(data_table, option))
            #@cloud.push(q.results)
          end
        end
      end
    end

    if params[:format] = 'csv'
      csv_data = CSV.generate() do |csv|
        csv << [@survey.title]
        @survey.questions.each do |q|
          csv << []
          csv << [q.prompt]
          if q.response_type == 'radio'
            if q.possible_responses.present?
              q.possible_responses.each do |k, v|
                csv << [radio_question_responses(q, k).length, v]
              end
              csv << []
            end
          end

          if q.response_type == 'checkbox'
            if q.possible_responses.present?
              q.possible_responses.each do |k, v|
                csv << [checkbox_question_responses(q, k).length, v]
              end
              csv << []
            end
          end

          if q.response_type == 'singleline'
            q.responses.each do |r|
              unless r.person.admin?
                csv << [r.text_response.html_safe]
              end
              csv << []
            end
          end

          if q.response_type == 'multiline'
            q.responses.each do |r|
              unless r.person.admin?
                csv << [r.text_response.html_safe]
              end
              csv << []
            end
          end

        end
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.csv { send_data csv_data }
    end

  end
end
