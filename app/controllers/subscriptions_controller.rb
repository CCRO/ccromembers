class SubscriptionsController < ApplicationController
  load_and_authorize_resource
  # GET /subscriptions 
  # GET /subscriptions.json
  def index
    @subscriptions = nil #the load_and_authorize_resource cancan method is loading all the subscriptions and we want to start with a clean slate here.
    if params[:company_id]
      @owner = Company.find(params[:company_id])
      @subscriptions = Subscription.where(owner_type: 'Company', owner_id: params[:company_id])
    end
    if params[:person_id]
      @owner = Person.find(params[:person_id])
      @subscriptions ||= Subscription.where(owner_type: 'Person', owner_id: params[:person_id])
    end
  
    @subscriptions ||= Subscription.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @subscriptions }
    end
  end

  # GET /subscriptions/1
  # GET /subscriptions/1.json
  def show
    @subscription = Subscription.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @subscription }
    end
  end

  # GET /subscriptions/new
  # GET /subscriptions/new.json
  def new
    @subscription = Subscription.new

    @owner = Company.find(params[:company_id]) if params[:company_id]
    @owner = Person.find(params[:person_id]) if params[:person_id]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @subscription }
    end
  end

  # GET /subscriptions/1/edit
  def edit
    @subscription = Subscription.find(params[:id])
  end

  # POST /subscriptions
  # POST /subscriptions.json
  def create
    @subscription = Subscription.new(params[:subscription])

    @subscription.owner = Company.find(params[:company_id]) if params[:company_id]
    @subscription.owner = Person.find(params[:person_id]) if params[:person_id]

    respond_to do |format|
      if @subscription.save
        format.html { redirect_to @subscription.owner, notice: 'Subscription was successfully created.' }
        format.json { render json: @subscription, status: :created, location: @subscription }
      else
        format.html { render action: "new" }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /subscriptions/1
  # PUT /subscriptions/1.json
  def update
    @subscription = Subscription.find(params[:id])

    respond_to do |format|
      if @subscription.update_attributes(params[:subscription])
        format.html { redirect_to @subscription.owner, notice: 'Subscription was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subscriptions/1
  # DELETE /subscriptions/1.json
  def destroy
    @subscription = Subscription.find(params[:id])
    @owner = @subscription.owner
    @subscription.destroy

    respond_to do |format|
      format.html { redirect_to polymorphic_url([@owner, :subscriptions]) }
      format.json { head :no_content }
    end
  end
end
