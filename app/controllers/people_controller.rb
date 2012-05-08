class PeopleController < ApplicationController
  before_filter :require_admin, :except => ['new', 'create']
  # GET /people
  # GET /people.json
  def index
    @people = Person.joins(:company).order('companies.name').accessible_by(current_ability) + Person.where('company_id IS NULL').accessible_by(current_ability) if params[:sort] == 'company'
    @people = Person.order(params[:sort]).accessible_by(current_ability) if params[:sort] && !@people

    @people = Person.accessible_by(current_ability) unless @people
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @people }
      format.xml { render xml: @people }
    end
  end

  # GET /people/1
  # GET /people/1.json
  def show
    @person = Person.find(params[:id])

    authorize! :read, @person
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @person }
      format.js
    end
  end

  # GET /people/new
  # GET /people/new.json
  def new
    @person = Person.new
    @companies = Company.pluck(:name)

    authorize! :create, Person
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @person }
    end
  end

  # GET /people/1/edit
  def edit
    @person = Person.find(params[:id])
    @companies = Company.pluck(:name)

    authorize! :edit, @person
    
  end

  # POST /people
  # POST /people.json
  def create
    if params[:person][:company_name]
      params[:person][:company] = Company.find_or_create_by_name(params[:person][:company_name])
      params[:person].delete(:company_name)
    end
    @person = Person.new(params[:person])

    authorize! :create, @person
        
    respond_to do |format|
      if @person.save
        format.html { redirect_to @person, notice: 'Person was successfully created.' }
        format.json { render json: @person, status: :created, location: @person }
      else
        format.html { render action: "new" }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /people/1
  # PUT /people/1.json
  def update
    if params[:person][:company_name]
      params[:person][:company] = Company.find_or_create_by_name(params[:person][:company_name])
      params[:person].delete(:company_name)
    end
    @person = Person.find(params[:id])

    authorize! :edit, @person
    
    respond_to do |format|
      if @person.update_attributes(params[:person])
        format.html { redirect_to @person, notice: 'Person was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  def destroy
    @person = Person.find(params[:id])
    @person.destroy

    authorize! :destroy, @person
    
    respond_to do |format|
      format.html { redirect_to people_url }
      format.json { head :no_content }
    end
  end
end
