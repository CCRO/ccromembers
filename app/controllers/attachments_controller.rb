class AttachmentsController < ApplicationController

  before_filter :lookup_group

  layout :conditional_layout

  def index
    @attachments = @group.attachments 
  end

  def show
    @attachment = Attachment.find(params[:id])
    
    @attachment.get_crocodoc_uuid! if @attachment.crocodoc_uuid.blank?

    session_key = Crocodoc::Session.create(@attachment.crocodoc_uuid, {
        'is_editable' => can?(:comment_on, @attachment),
        'user' => {
            'id' => current_user.id,
            'name' => current_user.name
        },
        'filter' => (can? :create_id, @group) ? 'all' : current_user.id,
        'is_admin' => current_user.admin?,
        'is_downloadable' => false,
        'is_copyprotected' => false,
        'is_demo' => false,
        'sidebar' => 'visible'
    })

    respond_to do |format|
      format.html { redirect_to "https://crocodoc.com/view/" + session_key } 
    end
  end

  def new
    @attachment = Attachment.new
  end

  def create
    @attachment = Attachment.new(params[:attachment])

    @attachment.author = current_user
    @attachment.owner = @group

    @attachment.save

    redirect_to group_attachments_path(@group)
  end

  def edit
    @attachment = Attachment.find(params[:id])
  end

  def update
    @attachment = Attachment.find(params[:id])

    @attachment.update_attributes(params[:attachment])

    @attachment.save

    redirect_to group_attachments_path(@group)
  end

  def destroy
    @attachment = Attachment.find(params[:id])

    @attachement.destroy

    redirect_to group_attachments_path(@group)
  end

  def lookup_group
    @group = Group.find(params[:group_id])
  end
  
  def conditional_layout
    (@group) ? 'group' : 'application' 
  end


end
