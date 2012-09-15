class SmartListsController < ApplicationController
  # GET /smart_lists
  # GET /smart_lists.json
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

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @smart_list }
    end
  end

  # GET /smart_lists/new
  # GET /smart_lists/new.json
  def new
    @smart_list = SmartList.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @smart_list }
    end
  end

  # GET /smart_lists/1/edit
  def edit
    @smart_list = SmartList.find(params[:id])
  end

  # POST /smart_lists
  # POST /smart_lists.json
  def create
    @smart_list = SmartList.new(params[:smart_list])

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
end
