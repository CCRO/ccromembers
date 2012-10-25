class MessagesController < ApplicationController

  before_filter :require_user

  before_filter :lookup_group

  layout :conditional_layout

  # GET /messages
  # GET /messages.json
  def index
    if params[:tag_name]
      @messages = Message.tagged_with(params[:tag_name]).not_archived.accessible_by(current_ability)
      @messages.sort! { |a,b| a.last_activity_time <=> b.last_activity_time }

      @archived_messages = Message.tagged_with(params[:tag_name]).archived.accessible_by(current_ability)
      @archived_messages.sort! { |a,b| a.last_activity_time <=> b.last_activity_time }
    else
      @messages = Message.not_archived.accessible_by(current_ability)
      @messages.sort! { |a,b| a.last_activity_time <=> b.last_activity_time }

      @archived_messages = Message.archived.accessible_by(current_ability)
      @archived_messages.sort! { |a,b| a.last_activity_time <=> b.last_activity_time }
    end

    if params[:page]
      @page = Page.find(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @messages }
    end
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
    @message = Message.find(params[:id])
    @commentable = @message
    @tag = @message.tags.pluck(:name).to_sentence if @message.tags.pluck(:name).present?
    @all_tags = all_tags
    impressionist(@message)
    authorize! :read, @message

    if params[:page]
      @page = Page.find(params[:page])
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @message }
    end
  end

  # GET /messages/new
  # GET /messages/new.json
  def new
    @message = Message.new
    if params[:group_id]
      @owner = Group.find(params[:group_id])
    end

    authorize! :read, Message
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @message }
    end
  end

  # GET /messages/1/edit
  def edit
    @message = Message.find(params[:id])

    authorize! :edit, @message
    
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = Message.new(params[:message])
    if params[:group_id]
      @message.owner = Group.find(params[:group_id]) 
    else
      @message.owner ||= default_company
    end
    @message.archived = false
    @message.author = current_user
    @message.published_at ||= Time.now
    
    authorize! :create, @message
    
    respond_to do |format|
      if @message.save
        format.html { redirect_to @message, notice: 'Message was successfully created.' }
        format.json { render json: @message, status: :created, location: @message }
      else
        format.html { render action: "new" }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /messages/1
  # PUT /messages/1.json
  def update
    @message = Message.find(params[:id])

    authorize! :edit, @message
    
    respond_to do |format|
      if @message.update_attributes(params[:message])
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message = Message.find(params[:id])
    @message.destroy

    authorize! :destory, @message
    
    if @group
      redirect_to @group
    else
      respond_to do |format|
        format.html { redirect_to messages_url }
        format.json { head :no_content }
      end
    end
  end

  def lookup_group
    if params[:id]
    @message = Message.find(params[:id])

    if @message.owner && @message.owner_type == 'Group'
      @group = @message.owner 
    end
  end

    if params[:group_id] 
      @group = Group.find(params[:group_id])
    end

    if @group
      @pages = @group.pages
      @articles = @group.posts
      @messages = @group.messages
      @group_document = @group.documents
      @smart_list = @group.people
    end
  end

  def conditional_layout
    (@group) ? 'group' : 'application' 
  end

  def archive
    message = Message.find(params[:id])
    authorize! :destory, message

    message.archive

    redirect_to message
  end

  def unarchive
    message = Message.find(params[:id])
    authorize! :destory, message

    message.unarchive

    redirect_to message
  end
end
