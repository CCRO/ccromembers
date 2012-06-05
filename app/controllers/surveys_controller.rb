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
  end
end
