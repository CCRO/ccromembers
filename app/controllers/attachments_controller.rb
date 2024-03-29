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

    @attachments.delete_if { |attachment| attachment.archived? }
    @attachments = @attachments.keep_if { |a| a.archived == false }


    @billboards = []
    Billboard.all.each {|a| @billboards << a if a.active }
      
  end

  def report
    authorize! :manage, Attachment

    a = Attachment.where(archived: false)
    @group_attachments = []
    @groups = []

    a.each do |a|
      if a.owner_type == "Group"
        @group_attachments << a

        unless @groups.include?(a.owner)
          @groups << a.owner
        end
      end
    end

    a.keep_if {|a| a.owner_type != "Group"}

    @viewing_level_public = a.select {|a| a.level == "public"}
    @viewing_level_basic = a.select {|a| a.level == "basic"}
    @viewing_level_pro = a.select {|a| a.level == "pro"}
    @viewing_level_subscriber = a.select {|a| a.level == "subscriber"}
    @viewing_level_individual_member = a.select {|a| a.level == "individual_member"}
    @viewing_level_company_member = a.select {|a| a.level == "company_member"}
    @viewing_level_leadership = a.select {|a| a.level == "leadership"}

    @comment_level_public = a.select {|a| a.comment_level == "public"}
    @comment_level_basic = a.select {|a| a.comment_level == "basic"}
    @comment_level_pro = a.select {|a| a.comment_level == "pro"}
    @comment_level_subscriber = a.select {|a| a.comment_level == "subscriber"}
    @comment_level_individual_member = a.select {|a| a.comment_level == "individual_member"}
    @comment_level_company_member = a.select {|a| a.comment_level == "company_member"}
    @comment_level_leadership = a.select {|a| a.comment_level == "leadership"}

    @download_level_public = a.select {|a| a.download_level == "public"}
    @download_level_basic = a.select {|a| a.download_level == "basic"}
    @download_level_pro = a.select {|a| a.download_level == "pro"}
    @download_level_subscriber = a.select {|a| a.download_level == "subscriber"}
    @download_level_individual_member = a.select {|a| a.download_level == "individual_member"}
    @download_level_company_member = a.select {|a| a.download_level == "company_member"}
    @download_level_leadership = a.select {|a| a.download_level == "leadership"}

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
      @attachment.level = "group_only"
      @attachment.comment_level = "group_only"
      @attachment.download_level = "group_only"
    end

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
    @attachment.get_crocodoc_uuid!

    if @group
      authorize! :create_in, @group
    else
      authorize! :create, Attachment
    end

    @attachment.save
    sleep(10.0)
    redirect_to refresh_attachment_path(@attachment)
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

    redirect_to :back
  end

  def refresh
    attachment = Attachment.find(params[:id])
    attachment.get_crocodoc_uuid!
    sleep(10.0)
    redirect_to attachment_path(attachment)
  end

  def status
    attachment = Attachment.find(params[:id])
    attachment.crocodoc_getstatus!

    redirect_to edit_attachment_path(attachment)
  end

  def destroy
    @attachment = Attachment.find(params[:id])

    authorize! :destory, @attachment

    # @attachment.destroy
    @attachment.archived = true
    @attachment.save

    redirect_to report_attachments_path
  end
  
  def crocodoc_webhook
    logger.info "CROCODOC_WEBHOOK: " + params.to_s 

    if params[:event] == "document.status"
      if attachment = Attachment.find_by_crocodoc_uuid(params[:uuid])
        attachment.crocodoc_status = params[:status]
        attachment.crocodoc_viewable = params[:viewable]
        attachment.save

        if false
          if params[:status] == "DONE"
              attachment.download_text_2
              attachment.download_thumbnail_2
          end
        end

      end

      render status: 200, text: :none
    end
  end

  def get_pic_and_text
    attachment = Attachment.find(params[:id])
    attachment.download_text_2
    attachment.download_thumbnail_2

    redirect_to :back
  end

  def lookup_group
    @surveys = Survey.where(active: true)
     if params[:group_id]
      @group = Group.find(params[:group_id])
      @pages = @group.pages.sort! { |a,b| a.position <=> b.position }
      @attachments = @group.attachments.select {|a| a.archived == false}
      @messages = @group.messages
      @group_document = @group.documents
      @smart_list = @group.people

      if current_user && @group.leadership.include?(current_user)
        @total_articles = @group.posts.order('updated_at DESC')
        @articles = @total_articles.limit(3)
      else
        @total_articles = @group.posts.select {|p| p.hidden == false}
        @total_articles = @total_articles.sort
        @articles = @total_articles
      end
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
