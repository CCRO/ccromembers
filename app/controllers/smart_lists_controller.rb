class SmartListsController < ApplicationController

  def index
    @smart_lists = SmartList.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @smart_lists }
    end
  end

  # GET /smart_lists/1
  # GET /smart_lists/1.json
  def show
    @smart_list = SmartList.find(params[:id])
    @list_items = @smart_list.people
    @tag = @smart_list.tags.pluck(:name).to_sentence if @smart_list.tags.pluck(:name).present?
    @all_tags = all_tags

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @smart_list }
    end
  end

  # GET /smart_lists/new
  # GET /smart_lists/new.json
  def new
    @smart_list = SmartList.new
    @people = Person.joins(:company).order('companies.name').accessible_by(current_ability) + Person.where('company_id IS NULL').accessible_by(current_ability) if params[:sort] == 'company'
    @people = Person.order(params[:sort]).accessible_by(current_ability) if params[:sort] && !@people
    @people = Person.accessible_by(current_ability) unless @people

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @smart_list }
    end
  end

  # GET /smart_lists/1/edit
  def edit
    @smart_list = SmartList.find(params[:id])
    @people = Person.joins(:company).order('companies.name').accessible_by(current_ability) + Person.where('company_id IS NULL').accessible_by(current_ability) if params[:sort] == 'company'
    @people = Person.order(params[:sort]).accessible_by(current_ability) if params[:sort] && !@people
    @people = Person.accessible_by(current_ability) unless @people
    @list_items = @smart_list.people
  end

  # POST /smart_lists
  # POST /smart_lists.json
  def create
    @smart_list = SmartList.new(params[:smart_list])
    @smart_list.name = params[:name]
    if params[:people]
      params[:people].each do |p|
        @smart_list.people << Person.where(id: p)
      end
    end  

    respond_to do |format|
      if @smart_list.save
        format.html { redirect_to @smart_list, notice: 'Smart list was successfully created.' }
        format.json { render json: @smart_list, status: :created, location: @smart_list }
      else
        format.html { render action: "new" }
        format.json { render json: @smart_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /smart_lists/1
  # PUT /smart_lists/1.json
  def update
    @smart_list = SmartList.find(params[:id])
    if params[:people]
      @smart_list.name = params[:name]
      @smart_list.description = params[:description]
      @smart_list.people = []
      params[:people].each do |p|
        @smart_list.people << Person.where(id: p)
      end
    end 

    respond_to do |format|
      if @smart_list.update_attributes(params[:smart_list])
        format.html { redirect_to @smart_list, notice: 'Smart list was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @smart_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /smart_lists/1
  # DELETE /smart_lists/1.json
  def destroy
    @smart_list = SmartList.find(params[:id])
    @smart_list.destroy

    respond_to do |format|
      format.html { redirect_to smart_lists_url }
      format.json { head :no_content }
    end
  end

  def duplicate
    smart_list = SmartList.find(params[:id])
    @duplicate = SmartList.new
    @duplicate.name = smart_list.name + " copy"
    @duplicate.description = smart_list.description
    smart_list.people.each do |p|
      @duplicate.people << Person.where(id: p)
    end 

    authorize! :create, @duplicate

    @duplicate.save 
    redirect_to smart_list_path(@duplicate)
  end

end
