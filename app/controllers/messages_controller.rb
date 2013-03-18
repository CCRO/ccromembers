class MessagesController < ApplicationController

  before_filter :require_user

  before_filter :lookup_group

  layout :conditional_layout

  # GET /messages
  # GET /messages.json
  def index
    if params[:tag_name]
      @messages = Message.tagged_with(params[:tag_name]).not_archived.delete_if { |message| cannot? :read, message }
      @messages.sort! { |a,b| a.last_activity_time <=> b.last_activity_time }

      @archived_messages = Message.tagged_with(params[:tag_name]).archived.delete_if { |message| cannot? :read, message }
      @archived_messages.sort! { |a,b| a.last_activity_time <=> b.last_activity_time }
    else
      @messages = Message.not_archived.delete_if { |message| cannot? :read, message }
      @messages.sort! { |a,b| a.last_activity_time <=> b.last_activity_time }

      @archived_messages = Message.archived.delete_if { |message| cannot? :read, message }
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

    message = "You do not have access to the discussion <strong>'#{@message.subject}'</strong> at this time. If you are interested in joining this discussion, please let us know."
    authorize! :read, @message, :message => message.html_safe

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

    message = "You do not have access needed to start a new discussion at this time. If you are interested in joining this discussion, please let us know."
    authorize! :read, Message
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @message }
    end
  end

  # GET /messages/1/edit
  def edit
    @message = Message.find(params[:id])

    message = "You do not have access needed to edit the discussion <strong>'#{@message.subject}'</strong> at this time. If you are interested in editing this discussion, please let us know."
    authorize! :edit, @message, :message => message.html_safe
    
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
    
    if @message.owner_type == 'Group'
      message = "You do not have access needed to create the discussion <strong>'#{@message.subject}'</strong> for this working group at this time. If you are still interested in creating this discussion, please let us know."
      authorize! :create_in, @message.owner, :message => message.html_safe
    else
      message = "You do not have access needed to create the discussion <strong>'#{@message.subject}'</strong> at this time. If you are still interested in creating this discussion, please let us know."
      authorize! :create, @message, :message => message.html_safe
    end

    respond_to do |format|
      if @message.save
        format.html { redirect_to polymorphic_path([@group, @message]) }
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

    our_message = "You do not have access needed to update the discussion <strong>'#{@message.subject}'</strong> at this time. If you are interested in updating this discussion, please let us know."
    authorize! :edit, @message, :message => our_message.html_safe
    
    respond_to do |format|
      if @message.update_attributes(params[:message])
        format.html { redirect_to polymorphic_path([@group, @message]), notice: 'Message was successfully updated.' }
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

    message = "You do not have access needed to delete the discussion <strong>'#{@message.subject}'</strong> at this time. If you are still interested in deleting this discussion, please let us know."
    authorize! :destroy, @message, :message => message.html_safe

    @message.destroy
    
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
      @pages = @group.pages.sort! { |a,b| a.position <=> b.position }
      @attachments = @group.attachments
      @attachments.delete_if { |attachment| attachment.archived? }
      @total_articles = @group.posts
      @articles = @total_articles.limit(3)
      @messages = @group.messages
      @group_document = @group.documents
      @smart_list = @group.people
    end
  end

  def conditional_layout
    (@group) ? 'group' : 'application' 
  end

  def archive
    @message = Message.find(params[:id])

    message = "You do not have access needed to archive the discussion <strong>'#{@message.subject}'</strong> at this time. If you are still interested in archiving this discussion, please let us know."
    authorize! :destory, @message, :message => message.html_safe

    @message.archive

    redirect_to message
  end

  def unarchive
    @message = Message.find(params[:id])

    message = "You do not have access needed to unarchive the discussion <strong>'#{@message.subject}'</strong> at this time. If you are still interested in unarchiving this discussion, please let us know."
    authorize! :destory, @message, :message => message.html_safe

    @message.unarchive

    redirect_to message
  end
end
