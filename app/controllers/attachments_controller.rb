class AttachmentsController < ApplicationController

  before_filter :lookup_group

  layout :conditional_layout

  def index
    if params[:search]
      @attachments = Attachment.find(@group.attachments.search(params[:search] + '*').map(&:id)) if @group
      @attachments ||= Attachment.find(Attachment.where(:owner_type => nil).search(params[:search] + '*').map(&:id))
    else
      @attachments = @group.attachments if @group
      @attachments ||= Attachment.where(:owner_type => nil)
    end
  end

  def show
    @attachment = Attachment.find(params[:id])
    
    @attachment.get_crocodoc_uuid! if @attachment.crocodoc_uuid.blank?
    @attachment.content = Crocodoc::Download.text(uuid) if @attachment.content.blank?

    @session_key = Crocodoc::Session.create(@attachment.crocodoc_uuid, {
        'is_editable' => can?(:comment_on, @attachment),
        'user' => {
            'id' => current_user.id,
            'name' => current_user.name
        },
        'filter' => 'all', # (can? :create_in, @group) ? 'all' : current_user.id
        'is_admin' => current_user.admin?,
        'is_downloadable' => false,
        'is_copyprotected' => false,
        'is_demo' => false,
        'sidebar' => 'visible'
    })

    respond_to do |format|
      format.html # { redirect_to "https://crocodoc.com/view/" + session_key } 
    end
  end

  def new
    @attachment = Attachment.new
  end

  def create
    @attachment = Attachment.new(params[:attachment])

    @attachment.author = current_user
    @attachment.owner = @group if @group

    @attachment.save

    redirect_to polymorphic_path([@group, :attachments])
  end

  def edit
    @attachment = Attachment.find(params[:id])
  end

  def update
    @attachment = Attachment.find(params[:id])

    @attachment.update_attributes(params[:attachment])

    @attachment.save

    redirect_to polymorphic_path([@group, :attachments])
  end

  def destroy
    @attachment = Attachment.find(params[:id])

    @attachment.destroy

    redirect_to polymorphic_path([@group, :attachments])
  end

  def lookup_group
    @group = Group.find(params[:group_id]) if params[:group_id]

    if @group
      @pages = @group.pages
      @total_articles = @group.posts
      @articles = @total_articles.limit(3)
      @messages = @group.messages
      @group_document = @group.documents
      @smart_list = @group.people
    end

  end
  
  def conditional_layout
    if params[:action] == 'show'
      'attachment_viewer'
    else
      (@group) ? 'group' : 'application' 
    end
  end


end
