class AttachmentsController < ApplicationController

  before_filter :lookup_group

  layout :conditional_layout

  def index
    if params[:search]
      @attachments = Attachment.find(@group.attachments.search(params[:search] + '*').map(&:id)) if @group
      @attachments ||= Attachment.find(Attachment.search(params[:search] + '*').map(&:id))
    else
      @attachments = @group.attachments if @group
      @attachments ||= Attachment.all
    end

    # @attachments.keep_if { |attachment| can? :read, attachment }
  end

  def search
      @results = @group.attachments.search(params) if @group
      @results ||= Attachment.search(params)
  end

  def show
    @attachment = Attachment.find(params[:id])
    
    @attachment.get_crocodoc_uuid! if @attachment.crocodoc_uuid.blank?

    authorize! :read, @attachment

    # logger.info "BEFORE USER: " + current_user.name
    # current_user ||= Person.new(id: 0, first_name: 'Guest', last_name: 'User')

    # logger.info "AFTER USER: " + current_user.name 

    @session_key = Crocodoc::Session.create(@attachment.crocodoc_uuid, {
        'is_editable' => @attachment.commentable? && can?(:comment_on, @attachment),
        'user' => {
            'id' => ((current_user) ? current_user.id : '0'),
            'name' => ((current_user) ? current_user.name : "Guest User")
        },
        'filter' => (@attachment.commentable? || ((current_user) ? current_user.admin? : false)) ? 'all' : 'none', # (can? :create_in, @group) ? 'all' : current_user.id
        'is_admin' => ((current_user) ? current_user.admin? : false),
        'is_downloadable' => (@attachment.downloadable? && can?(:download, @attachment)),
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

    if @group
      authorize! :create_in, @group
    else
      authorize! :create, Attachment
    end
  end

  def create
    params[:attachment][:options] = OpenStruct.new( params[:attachment][:options] )

    @attachment = Attachment.new(params[:attachment])

    @attachment.author = current_user
    @attachment.owner = @group if @group

    if @group
      authorize! :create_in, @group
    else
      authorize! :create, Attachment
    end

    @attachment.save

    redirect_to polymorphic_path([@group, :attachments])
  end

  def edit
    @attachment = Attachment.find(params[:id])
    authorize! :edit, @attachment

  end

  def update
    @attachment = Attachment.find(params[:id])

    authorize! :edit, @attachment


    params[:attachment][:options] = OpenStruct.new( params[:attachment][:options] )

    @attachment.update_attributes(params[:attachment])

    @attachment.save

    redirect_to polymorphic_path([@group, :attachments])
  end

  def refresh
    attachment = Attachment.find(params[:id])

    attachment.download_text
    attachment.download_thumbnail
   end

  def destroy
    @attachment = Attachment.find(params[:id])

    authorize! :destory, @attachment

    @attachment.destroy

    redirect_to polymorphic_path([@group, :attachments])
  end
  
  def crocodoc_webhook
    logger.info "CROCODOC_WEBHOOK: " + params.to_s 

    if params[:event] == "document.status"
      if attachment = Attachment.find_by_crocodoc_uuid(params[:uuid])
        attachment.crocodoc_status = params[:status]
        attachment.crocodoc_viewable = params[:viewable]
        attachment.save

        if params[:status] == "DONE"
            attachment.download_text
            attachment.download_thumbnail
        end

      end

      render status: 200, text: :none
    end


  end

  def lookup_group
    @group = Group.find(params[:group_id]) if params[:group_id]

    if @group
      @pages = @group.pages.sort! { |a,b| a.position <=> b.position }
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
