class BillboardsController < ApplicationController
  load_and_authorize_resource
  # GET /billboards
  # GET /billboards.json
  def index
    @billboards = Billboard.all

    unless current_user && current_user.admin?
      redirect_to :root
    else

      unless @billboards.empty?
        @active_billboards = []
        @inactive_billboards = []
        @archived_billboards = []

        @billboards.each {|a| @active_billboards << a if a.active }
        @billboards.each {|a| @inactive_billboards << a if (a.active == false && a.archived == false) }
        @billboards.each {|a| @archived_billboards << a if a.archived }

      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @billboards }
      end
    end
  end

  def archived
    @billboards = Billboard.all
    @archived_billboards = []
    @billboards.each {|a| @archived_billboards << a if a.archived }

    respond_to do |format|
      format.html # archived.html.erb -- right?
    end
  end

  # GET /billboards/1
  # GET /billboards/1.json
  def show
    @billboard = Billboard.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @billboard }
    end
  end

  # GET /billboards/new
  # GET /billboards/new.json
  def new
    @billboard = Billboard.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @billboard }
    end
  end

  # GET /billboards/1/edit
  def edit
    @billboard = Billboard.find(params[:id])
  end

  # POST /billboards
  # POST /billboards.json
  def create
    @billboard = Billboard.new(params[:billboard])

    respond_to do |format|
      if @billboard.save
        format.html { redirect_to edit_billboard_path(@billboard), notice: 'Billboard was successfully created.' }
        format.json { render json: @billboard, status: :created, location: @billboard }
      else
        format.html { render action: "new" }
        format.json { render json: @billboard.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /billboards/1
  # PUT /billboards/1.json
  def update
    @billboard = Billboard.find(params[:id])

    if @billboard.archived == true
      @billboard.active = false
      @billboard.save
    end

    respond_to do |format|
      if @billboard.update_attributes(params[:billboard])
        format.html { redirect_to billboards_path, notice: 'Billboard was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @billboard.errors, status: :unprocessable_entity }
      end
    end
  end

  def duplicate
    old_billboard = Billboard.find(params[:id])
    @billboard = Billboard.new()
    @billboard.title = "#{old_billboard.title} Copy"
    @billboard.body = old_billboard.body
    @billboard.active = false
    @billboard.archived = false

    @billboard.save 
    redirect_to edit_billboard_path(@billboard)
  end

  def archive
    @billboard = Billboard.find(params[:id])

    @billboard.archived = true
    @billboard.active = false
    @billboard.save

    respond_to do |format|
      if @billboard.update_attributes(params[:billboard])
        format.html { redirect_to billboards_path, notice: 'Billboard was successfully archived.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @billboard.errors, status: :unprocessable_entity }
      end
    end
  end

  def unarchive
    @billboard = Billboard.find(params[:id])

    @billboard.archived = false
    @billboard.save

    respond_to do |format|
      if @billboard.update_attributes(params[:billboard])
        format.html { redirect_to billboards_path, notice: 'Billboard was successfully un-archived.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @billboard.errors, status: :unprocessable_entity }
      end
    end
  end

  def activate
    @billboard = Billboard.find(params[:id])

    @billboard.archived = false
    @billboard.active = true
    @billboard.save

    respond_to do |format|
      if @billboard.update_attributes(params[:billboard])
        format.html { redirect_to billboards_path, notice: 'Billboard was successfully actiavated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @billboard.errors, status: :unprocessable_entity }
      end
    end
  end

  def deactivate
    @billboard = Billboard.find(params[:id])

    @billboard.active = false
    @billboard.save

    respond_to do |format|
      if @billboard.update_attributes(params[:billboard])
        format.html { redirect_to billboards_path, notice: 'Billboard was successfully de-actiavated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @billboard.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /billboards/1
  # DELETE /billboards/1.json
  def destroy
    @billboard = Billboard.find(params[:id])
    @billboard.destroy

    respond_to do |format|
      format.html { redirect_to billboards_url }
      format.json { head :no_content }
    end
  end
end
