class PeopleController < ApplicationController
  #before_filter :require_admin, :except => ['new', 'create', 'show', 'su']
  # GET /people
  # GET /people.json
  def index
    @people = Person.joins(:company).order('companies.name').accessible_by(current_ability) + Person.where('company_id IS NULL').accessible_by(current_ability) if params[:sort] == 'company'
    @people = Person.order(params[:sort]).accessible_by(current_ability) if params[:sort] && !@people
    @people = Person.accessible_by(current_ability) unless @people
    authorize! :read, Person
    
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
    @group_memberships = Group.pluck(:id).zip(Group.pluck(:id).map { |group_id| (@person.groups.where(:id => group_id).present?) ? 1 : 0 })

    if @person.highrise_id.present?
      # if !@person.highrise_cached_at || @person.highrise_cached_at > 2.hours.ago
      #   @highrise = Highrise::Person.find(@person.highrise_id) 
      #   @person.highrise_cache = @highrise
      #   @person.highrise_cached_at = Time.now
      #   @person.save
      # else
      #   @highrise = @person.highrise_cache
      # end
    else
      @possible_highrises = Highrise::Person.find_all_across_pages(:params => { :email => @person.email})
    end

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
    cookies[:url_after_signup] = session[:url_return_to]
    
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

  # GET /people/1/edit
  def su
    @su_user = Person.find(params[:id])
    @original_user = Person.find(session[:user_id])

    logger.info "SU ATTEMPT: " + @original_user.name + " is trying to su to " + @su_user.name

    if @original_user == @su_user
      session.delete(:su_user_id)
    else
       authorize! :su, @original_user
       session[:su_user_id] = @su_user.id
    end

    redirect_to root_path
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
        @person.send_activation
        format.html { redirect_to activation_path }
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
        format.html { redirect_to :back, notice: 'Person was successfully updated.' }
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

  def resend_activation
    @person = Person.find(params[:id])

    authorize! :create, @person

    @person.send_activation

    redirect_to :back, :flash => {success: "Activation email resent to user."}
  end
 
  def send_mobile_activation
    @person = Person.find(params[:id])

    authorize! :create, @person

    @person.send_mobile_activation

    redirect_to :back, :flash => {success: "Mobile activation email resent to user."}
  end
end
