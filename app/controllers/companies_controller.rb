class CompaniesController < ApplicationController
  before_filter :require_admin

  def index
    @companies = Company.order(params[:sort]) if params[:sort] && !@companies

    @companies = Company.all unless @companies
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @companies }
    end
  end

  # GET /people/1
  # GET /people/1.json
  def show
    @company = Company.find(params[:id])
    @subscriptions = Subscription.where(owner_type: 'Company', owner_id: @company.id)
    @people = @company.people

  unless @company.highrise_id.present?
    @possible_highrises = Highrise::Company.find_all_across_pages(:params => { :name => @company.name})
  end


    authorize! :read, @company

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @company }
    end
  end

  # GET /people/new
  # GET /people/new.json
  def new
    @company = Company.new

    authorize! :create, @company

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @company }
    end
  end

  # GET /people/1/edit
  def edit
    @company = Company.find(params[:id])

    authorize! :update, @company

  end

  # POST /people
  # POST /people.json
  def create
    @company = Company.new(params[:company])

    authorize! :create, @company

    respond_to do |format|
      if @company.save
        format.html { redirect_to @company, notice: 'Company was successfully created.' }
        format.json { render json: @company, status: :created, location: @company }
      else
        format.html { render action: "new" }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /people/1
  # PUT /people/1.json
  def update
    @company = Company.find(params[:id])

    authorize! :update, @company

    respond_to do |format|
      if @company.update_attributes(params[:company])
        format.html { redirect_to :back, notice: 'Company was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  def destroy
    @company = Company.find(params[:id])
    @company.destroy

    authorize! :destroy, @company

    respond_to do |format|
      format.html { redirect_to companies_url }
      format.json { head :no_content }
    end
  end
end
