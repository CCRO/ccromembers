class PagesController < ApplicationController

	layout 'page'
  
  def index
    if params[:filter] 
      if params[:filter] == 'drafts'
        authorize! :create, Page
        @pages = Page.where(:published => false).order('updated_at DESC')
      end
      if params[:filter] == 'my_drafts'
        authorize! :create, Page
        @pages = Page.where(:published => false, author_id: current_user).order('updated_at DESC')
      end
      if params[:filter] == 'archive'
        authorize! :create, Page
        @pages = Version.where(item_type: "Page", event: "destroy").map { |v| v.reify }.reverse.uniq
      end
      if params[:filter] == 'summit'
        @pages = Page.where(published: true).tagged_with("summit")
      end
    end
    if params[:tag_name]
      @pages = Page.where(published: true).tagged_with(params[:tag_name])
    end
    
    @pages ||= Page.where(:published => true).order('published_at DESC')
    authorize! :create, @page
    
    
    respond_to do |format|
      format.html
      format.rss { render :layout => false }
      format.atom { render :layout => false }
    end
  end
  
  def draft
    @pages = Page.where(:published => false).order('updated_at DESC')
    @my_pages = Page.where(published: false, author_id: current_user).order('updated_at DESC')
  end
  
  def show
    @editors = []
    @editors = Person.where(role: ['editor', 'admin', 'super_admin'])
    @editors += Person.where(role: nil)
    
    if params['token']
      @page = Page.find_by_viewing_token(params[:token])
    else 
      @page = Page.find(params[:id])
      @tag = @page.tags.pluck(:name).to_sentence if @page.tags.pluck(:name).present?
      @category = Page.where(published: true).tagged_with(@tag)
      @articles = Post.where(published: true).tagged_with(@tag)
      @messages = Message.tagged_with(@tag)
      @commentable = @page
      authorize! :read, @page
    end

    respond_to do |format|
      format.html
      format.pdf { doc_raptor_send }
    end
  end

  def share
    page = Page.find(params[:id])
    authorize! :read, page
    page.share_by_email(params[:email_list], current_user)
    redirect_to page
  end

  
  def new
    @page = Page.new
  end
  
  def create
    @page = Page.new(params[:page])
    
    @page.body = "Here is the start of a new page!"
    @page.owner = current_user
    @page.author = current_user
    @page.published = false
    @page.level ||= 'public'
    @page.generate_token(:viewing_token)
    
    authorize! :create, @page
    
    if @page.save
      redirect_to page_path(@page)
    else
      flash[:notice] = "Please give your new draft a title."
      redirect_to draft_pages_path
    end
  end
  
  def claim
    page = Page.find(params[:id])
    
    authorize! :edit, page
    
    page.author = current_user
    page.save
    
    redirect_to page
  end
  
  def edit
    page = Page.find(params[:id])
    unless page.locked?
      page.lock(current_user)
      page.save
    end
    redirect_to "/editor" + page_path(page)
  end

  def update
    page = Page.find(params[:id])

    authorize! :edit, page
    
    if params[:content]
      page.title = params[:content][:page_title][:value]
      page.title = "Untitled" if page.title == "<br>" || page.title.blank?
      page.body = params[:content][:page_body][:value]
      page.header_picture = params[:content][:pages_header_image][:value]
      page.author ||= current_user
      page.unlock
      page.save! 
      render text: ""
    else
      page.update_attributes(params[:page])
      redirect_to page_path(page)
    end

  end
  
  def publish
    @page = Page.find(params[:id])
    @page.published = params[:published]

    authorize! :publish, @page

    @page.save 
    redirect_to page_path(@page)
  end

  def restore
    @page = Version.where(item_type: 'Page', item_id: params[:id], event: 'destroy').last.reify
    @page.published = false
    @page.author = current_user
    @page.save!
    redirect_to page_path(@page)
  end

  def duplicate
    page = Page.find(params[:id])
    @duplicate = Page.new(page.attributes)
    @duplicate.owner = current_user
    @duplicate.title += " Copy"
    @duplicate.generate_token
    @duplicate.published = false
    @duplicate.locked = nil
    @duplicate.locker_id = nil
    @duplicate.locked_at = nil
    @duplicate.tag_list = nil

    authorize! :create, @duplicate

    @duplicate.save 
    redirect_to page_path(@duplicate)
  end

  def reset_token
    @page = Page.find(params[:id])
    @page.generate_token(:viewing_token)

    authorize! :publish, @page

    @page.save 
    redirect_to page_path(@page)
  end
  
  def destroy
    @page = Page.find(params[:id])
    
    authorize! :destroy, @page
    
    if @page.destroy
      redirect_to draft_pages_path
    else
      redirect_to page_path(@page)
    end
  end

  def doc_raptor_send(options = { })
    default_options = { 
      :name             => controller_name,
      :document_type    => request.format.to_sym,
      :test             => ! Rails.env.production?,
    }
    options = default_options.merge(options)
    options[:document_content] ||= render_to_string
    ext = options[:document_type].to_sym
    
    response = DocRaptor.create(options)
    if response.code == 200
      send_data response, :filename => "#{options[:name]}.#{ext}", :type => ext
    else
      render :inline => response.body, :status => response.code
    end
  end
end
