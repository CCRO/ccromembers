class PeopleController < ApplicationController
  #before_filter :require_admin, :except => ['new', 'create', 'show', 'su']
  # GET /people
  # GET /people.json

  has_mobile_fu

  def index
    if params[:q]
      @people = Person.find(Person.accessible_by(current_ability).search(params).map(&:id))
    else
      @people = Person.joins(:company).order('companies.name').accessible_by(current_ability) + Person.where('company_id IS NULL').accessible_by(current_ability) if params[:sort] == 'company'
      @people = Person.accessible_by(current_ability).sort { |a, b| a.level <=> b.level } if params[:sort] == 'level' && !@people
      @people = Person.order(params[:sort]).accessible_by(current_ability) if params[:sort] && !@people
      @people = Person.joins(:company).order('companies.name').accessible_by(current_ability) + Person.where('company_id IS NULL').accessible_by(current_ability) unless @people
    end
    
    if params[:format] = 'csv'
      csv_data = CSV.generate() do |csv|
        csv << ['name', 'email', 'company', 'level']
        @people.each do |person|
          csv << [person.name, person.email, person.company_name, person.level] # person.attributes.values_at(*column_names)
        end
      end
    end

    if current_user && current_user.admin?
      if params[:as_member] == "true"
        @as_member = true
      else
        @as_member = false
      end

      if params[:as_public] == "true"
        @as_public = true
      else
        @as_public = false
      end

      if params[:primary_contacts] == "true"
        list = Company.select {|c| c.primary_contact.present?}
        @primary_contacts = []

        list.each do |c|
          @primary_contacts << Person.find(c.primary_contact)
        end
      end
    end



    respond_to do |format|
      format.mobile {render :layout => '/layouts/blank.html.erb'}
      format.tablet {render :layout => '/layouts/blank.html.erb'}
      format.html # index.html.erb
      format.json { render json: @people }
      format.csv { send_data csv_data }
      format.xml { render xml: @people }
    end
  end

  # GET /people/1
  # GET /people/1.json
  def show
    @person = Person.find(params[:id])
    @active_groups = Group.select {|g| g.active == true }
    @group_memberships = Group.pluck(:id).zip(Group.pluck(:id).map { |group_id| (@person.groups.where(:id => group_id).present?) ? 1 : 0 })
    @subscriptions = Subscription.where(owner_type: 'Person', owner_id: params[:id])
    if @person.company != nil
    @subscriptions += Subscription.where(owner_type: 'Company', owner_id: @person.company.id)
    end

    
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
      @possible_highrises = Highrise::Person.find_all_across_pages(:params => { :email => @person.email}) #this is breaking things?
    end

    authorize! :read, @person
    
    respond_to do |format|
      format.mobile {render :layout => '/layouts/blank.html.erb'}
      format.tablet {render :layout => '/layouts/blank.html.erb'}
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
      format.mobile {render :layout => '/layouts/blank.html.erb'}
      format.tablet {render :layout => '/layouts/blank.html.erb'}
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
    @person.avatar ||= File.open(Rails.root.join('app', 'assets', 'images', 'head.jpg'))

    authorize! :create, @person
        
    respond_to do |format|
      if @person.save
        @person.send_activation
        format.html { redirect_to activation_path }
        format.mobile {render :layout => '/layouts/blank.html.erb'}
        format.tablet {render :layout => '/layouts/blank.html.erb'}
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
        format.html { redirect_to edit_person_path(@person), notice: 'Person was successfully updated.' }
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

    authorize! :destroy, @person
    
    m = Membership.where(person_id: @person.id)
    m.each {|m| m.destroy}

    @person.destroy

    
    
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

  #############################

  def request_company
    @person = Person.find(params[:id])
    @company_name = params[:company]
    @survey = Survey.find(params[:survey])

    if (@survey.active == true) || (@survey.owner.people.include? current_user)
      @person.request_company(@company_name, @survey)
      redirect_to :back, :flash => {success: "Thank you, we will follow up on your request shortly."}
    else
      redirect_to :back, :flash => {success: "This survey is not active at this time so your request has not been sent."}
    end
    
  end

  def make_primary
    @person = Person.find(params[:id])
    if @person.company.present?
      company = @person.company
      company.primary_person_id = @person.id
      if company.save
        redirect_to :back, :flash => {success: "Primary contact for #{company.name} is set to #{@person.name}."}
      else
        redirect_to :back, :flash => {error: "Error saving company."}
      end
    else
      redirect_to :back, :flash => {error: "#{@person.name} is not part of a company. Cannot set to primary contact."}
    end
  end

  def suggest_primary
    @person = Person.find(params[:id])
    @first = params[:first]
    @last = params[:last]
    @email = params[:email]
    @survey = Survey.find(params[:survey])
    
    if (@survey.active == true) || (@survey.owner.people.include? current_user)
      @person.suggest_primary(@first, @last, @email)
      redirect_to :back, :flash => {success: "Thank you, we will follow up on your recommendation shortly."}
    else
      redirect_to :back, :flash => {success: "This survey is not active at this time so your suggestion has not been sent."}
    end

  end 

  def request_survey_access
    @person = Person.find(params[:id])
    @primary = @person.company.primary_person
    @survey = Survey.find(params[:survey])

    if (@survey.active == true) || (@survey.owner.people.include? current_user)
      @person.request_survey_access(@survey)
      redirect_to :back, :flash => {success: "Your request has been sent to #{@primary.name}"}
    else
      redirect_to :back, :flash => {success: "This survey is not active so your request has not been sent."}
    end

  end 

  def invite_user
    @person = Person.find(params[:id])
    @first = params[:first]
    @last = params[:last]
    @email = params[:email]
    @survey = Survey.find(params[:survey])

    if (@survey.active == true) || (@survey.owner.people.include? current_user)
      @person.invite_user(@first, @last, @email)
      redirect_to :back, :flash => {success: "If #{@first} #{@last} is already in the CCRO system, we will add them to your company. Otherwise we will send them an invite."}
    else
      redirect_to :back, :flash => {success: "This survey is not active so your request has not been processed."}
    end
  end

  ##################################  
 
  def send_mobile_activation
    @person = Person.find(params[:id])

    authorize! :create, @person

    @person.send_mobile_activation

    redirect_to :back, :flash => {success: "Mobile activation email resent to user."}
  end
end
