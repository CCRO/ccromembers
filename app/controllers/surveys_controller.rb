class SurveysController < ApplicationController
  
  
  layout 'survey'#, :except => :show
  before_filter :require_user
  
  
  def index
    @surveys = Survey.all
  end

  def show
    @survey = Survey.find(params[:id])
    @response = Response.new
    
    authorize! :read, @survey
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
    @chart = Array.new
    @cloud = Array.new
    @survey.questions.each do |q|
      if q.results.present?
        if q.response_type == 'radio' || q.response_type == 'checkbox'
          data_table = GoogleVisualr::DataTable.new

          # Add Column Headers 
          data_table.new_column('string', 'Prompt' ) 
          data_table.new_column('number', 'Responses') 

          # Add Rows and Values 
          data_table.add_rows(q.results)
    
          option = { width: 800, height: 480, title: q.prompt, :is3D => true }
        end
        case q.response_type
        when 'radio'
          @chart.push(GoogleVisualr::Interactive::PieChart.new(data_table, option))
        when 'checkbox'
          @chart.push(GoogleVisualr::Interactive::BarChart.new(data_table, option))
        when 'singleline', 'multiline'
          @cloud.push(q.results)
        end
      end
    end
  end
end
