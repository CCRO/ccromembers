class GroupsController < ApplicationController
  # GET /groups
  # GET /groups.json

  layout 'group'

  skip_before_filter :verify_authenticity_token, :only => [:update]

  def index
    @groups = Group.all
    @active_groups = @groups.select {|g| g.active == true }
    @inactive_groups = @groups.select {|g| g.active == false }

    authorize! :read, @groups , :message => "You do not have the access to view all groups in this manner."

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    @billboards = []
    Billboard.all.each {|a| @billboards << a if a.active }
    @group = Group.find(params[:id])

    message = "You do not have access to the working group <strong>'#{@group.name}'</strong> at this time. If you are interested in joining this group, please let us know."
    authorize! :read, @group, :message => message.html_safe

    redirect_to group_posts_path(@group)
  end

  def show_activity
    @group = Group.find(params[:id])

    @pages = @group.pages.sort! { |a,b| a.position <=> b.position }
    @total_articles = @group.posts
    @articles = @total_articles.limit(3)
    @messages = @group.messages
    @comments = @group.comments
    @attachments = @group.attachments.where(archived: false)
    @group_document = @group.documents
    @smart_list = @group.people
    @co_chairs = @group.memberships.where(fuction: 'chair').map { |membership| membership.person }
    @coordinators = @group.memberships.where(fuction: 'coordinator').map { |membership| membership.person }
    @group_resources = (@pages + @articles + @messages + @comments + @attachments).sort_by(&:updated_at).reverse
    
    message = "You do not have the access needed to see the activities for the working group: <strong>#{@group.name}</strong>. If you are interested in joining this group, please let us know."
    authorize! :read, @group, :message => message.html_safe


    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @group }
    end
  end

  def permissions
    @group = Group.find(params[:id])
    @memberships = @group.memberships

    @pages = @group.pages.sort! { |a,b| a.position <=> b.position }
    @total_articles = @group.posts
    @articles = @total_articles.limit(3)
    @messages = @group.messages
    @group_document = @group.documents
    @smart_list = @group.people


    message = "You are unable to set the permissions for the working group: <strong>#{@group.name}</strong>."
    authorize! :manage, @group, :message => message.html_safe

  end

  # GET /groups/new
  # GET /groups/new.json
  def new
    @group = Group.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group }
    end
  end

  def join
    @group = Group.find(params[:id])
    @group.people << current_user
    @group.save
    redirect_to @group
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
    @left_over_people = Person.all - @group.people
    @left_over_people.sort! { |a,b| a.last_name.downcase <=> b.last_name.downcase }
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(params[:group])

    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: 'Group was successfully created.' }
        format.json { render json: @group, status: :created, location: @group }
      else
        format.html { render action: "new" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.json
  def update
    @group = Group.find(params[:id])
    @group.overview_page = params[:overview_page]

    if params[:status] == 'active'
      @group.active = true
      @group.archived = false
      
    elsif params[:status] == 'inactive'
      @group.active = false
     
    elsif params[:status] == 'archived'
      @group.active = false
      @group.archived = true
      

    end

    respond_to do |format|
      if @group.update_attributes(params[:group])
        format.html { redirect_to groups_path, notice: 'Group was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  def archive
    @group = Group.find(params[:id])

    @group.archived = true
    @group.active = false
    @group.save

    respond_to do |format|
      if @group.update_attributes(params[:group])
        format.html { redirect_to groups_path, notice: 'Group was successfully archived.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  def unarchive
    @group = Group.find(params[:id])

    @group.archived = false
    @group.save

    respond_to do |format|
      if @group.update_attributes(params[:group])
        format.html { redirect_to groups_path, notice: 'Group was successfully un-archived.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  def archived
    @groups = Group.all
    @archived_groups = @groups.select {|g| g.archived }

    respond_to do |format|
      format.html # archived.html.erb -- right?
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to groups_url }
      format.json { head :no_content }
    end
  end
end
