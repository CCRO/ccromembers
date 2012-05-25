class SurveysController < ApplicationController
  
  layout 'survey'#, :except => :show
  
  def index
    @surveys = Survey.all.sort.reverse
  end

  def show
    @survey = Survey.find(params[:id])
  end

  def new
    @survey = Survey.new
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
  end

  def update
    @survey = Survey.find(params[:id])
  end

  def destroy
    @survey = Survey.find(params[:id])
    
    authorize! :destroy, @survey

    @survey.destroy
    
    redirect_to surveys_path
  end

  def report
    @survey = Survey.find(params[:id])
  end
end
