class PagesController < ApplicationController

  include ActionView::Helpers::TextHelper

  before_filter :lookup_group

  layout :conditional_layout
  
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
      if params[:filter] == 'active'
        @pages = Page.where(:published => true).order('published_at DESC')
      end
    end

    @groups = Group.all

    if params[:tag_name]
      @pages = Page.where(published: true).tagged_with(params[:tag_name])
    end
    
    if params[:group_id]
      @pages = Group.find(params[:group_id]).pages.order('position DESC')
    end

    @pages ||= Page.order('position DESC')

    if params[:sort] == 'Published'
      @pages.sort! {|a,b| (a.published ? 1 : 2) <=> (b.published ? 1 : 2) }
    end

    if params[:sort] == 'Category'
      @pages.keep_if { |a| a.tags.pluck(:name).present? }
      @pages.sort! { |a,b| a.tags.pluck(:name).first.downcase <=> b.tags.pluck(:name).first.downcase }
    end

    if params[:sort] == 'Owner'
      @pages.keep_if { |a| a.owner.present? && a.owner.class.name == 'Group' }
      @pages.sort! { |a,b| a.owner.name.downcase <=> b.owner.name.downcase }
    end

    if params[:sort] == 'Name'
      @pages.sort! { |a,b| a.title.downcase <=> b.title.downcase }
    end

    if params[:sort] == 'Position'
      @pages.sort! { |a,b| a.position <=> b.position }
    end


    @all_tags = all_tags
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

    if params['token']
      @page = Page.find_by_viewing_token(params[:token])
    else 
      @page = Page.find(params[:id])
      @tag = @page.tags.pluck(:name).to_sentence if @page.tags.pluck(:name).present?
      @all_tags = all_tags
      unless @group
        if @page.published == true
          @category = Page.where(published: true).tagged_with(@tag).sort! { |a,b| a.position <=> b.position }
          @articles = Post.where(published: true).tagged_with(@tag)
        else
          @category = Page.tagged_with(@tag).sort! { |a,b| a.position <=> b.position }
          @articles = Post.tagged_with(@tag)
        end
        @messages = Message.tagged_with(@tag)
        @smart_list = Array.new
        @smart_list = SmartList.tagged_with(@tag).first.people if SmartList.tagged_with(@tag).present?
      end

      unless @page.stretch
        @billboards = []
        Billboard.all.each {|a| @billboards << a if a.active }
      end

      @commentable = @page
      
      page_title = strip_tags @page.title


      if current_user
        message = "You are unable to view the page: <strong>#{page_title}</strong>. The access level needed to view this page is #{@page.level}, your access level is currently #{current_user.level}."
      else
        message = "You are unable to view the page: <strong>#{page_title}</strong>. The access level needed to view this page is #{@page.level}. You are currently not logged in."
      end
      authorize! :read, @page, :message => message.html_safe
    end

    @editors = []
    @editors = Person.where(role: ['editor', 'admin', 'super_admin'])
    @editors += Person.where(role: nil)


    if @page.owner_type == 'Group' && !@group
      redirect_to polymorphic_path([@page.owner, @page])
    else
      respond_to do |format|
        format.html
        format.pdf { doc_raptor_send }
      end
    end
  end

  def share
    page = Page.find(params[:id])
    page_title = strip_tags page.title
    if current_user
      message = "You are unable to share the page: <strong>#{page_title}</strong>. The access level needed to share this page is #{page.level}, your access level is currently #{current_user.level}."  
    else
      message = "You are unable to share the page: <strong>#{page_title}</strong>. The access level needed to share this page is #{page.level}. You are currently not logged in."
    end
    
    authorize! :read, page, :message => message.html_safe
    list_of_people = Person.all

    people = []
    if params[:test] == 'yes'
      people << current_user
    end

    if params[:working_group] == 'yes'
      people += page.owner.people
    end

    if params[:working_group_leadership] == 'yes'
      people += page.owner.leadership
    end

    if params[:leadership] == 'yes'
      people += list_of_people.select {|p| p.level == 'leadership'}
      people += list_of_people.select {|p| p.level == 'admin'}
    end

    if params[:company] == 'yes'
      people += list_of_people.select {|p| p.level == 'company_member'}
    end

    if params[:individual] == 'yes'
      people += list_of_people.select {|p| p.level == 'individual_member'}
    end

    if params[:basic] == 'yes'
      people += list_of_people.select {|p| p.level == 'basic' || p.level == 'pro'}
    end

    if params[:contacts] == 'yes'
      people += Contact.all
    end

    unless people == []
      page.share_by_email(people, params[:my_subject], params[:short_message], current_user)
    end

    if params[:email_who] == 'my_list'
      page.share_by_email(params[:email_list], params[:my_subject], params[:short_message], current_user)
    end
      
    redirect_to page
  end

  
  def new
    @page = Page.new
    @owner = @group if @group
    @page.position = 1
  end
  
  def create
    @page = Page.new(params[:page])
    
    @page.body = "Here is the start of a new page!"
    @page.owner = @group if @group
    @page.author = current_user
    @page.published = false
    @page.level ||= 'public'
    @page.position = @page.id
    @page.generate_token(:viewing_token)
    page_title = strip_tags @page.title
    message = "You are unable to create the page: <strong>#{page_title}</strong> at this time. If you are interested in creating this page, please let us know."
    authorize! :create, @page, :message => message.html_safe
    
    if @page.save
      redirect_to polymorphic_path([@group, @page])
    else
      flash[:notice] = "Please give your new draft a title."
      redirect_to draft_pages_path
    end
  end
  
  def claim
    page = Page.find(params[:id])
    page_title = strip_tags page.title
    message = "You are unable to claim the page: <strong>#{page_title}</strong> at this time."
    authorize! :edit, page, :message => message.html_safe
    
    page.author = current_user
    page.save
    
    redirect_to page
  end
  
  def edit
    @page = Page.find(params[:id])
    unless @page.locked?
      @page.lock(current_user)
      @page.save
    end

    @tag = @page.tags.pluck(:name).to_sentence if @page.tags.pluck(:name).present?
    @all_tags = all_tags
    unless @group
      if @page.published == true
        @category = Page.where(published: true).tagged_with(@tag).sort! { |a,b| a.position <=> b.position }
        @articles = Post.where(published: true).tagged_with(@tag)
      else
        @category = Page.tagged_with(@tag).sort! { |a,b| a.position <=> b.position }
        @articles = Post.tagged_with(@tag)
      end
      @messages = Message.tagged_with(@tag)
      @smart_list = Array.new
      @smart_list = SmartList.tagged_with(@tag).first.people if SmartList.tagged_with(@tag).present?
    end

    @commentable = @page
    @people = Person.find(:all, :order => 'last_name')
    
    page_title = strip_tags @page.title

    if current_user
      message = "You are unable to view the page: <strong>#{page_title}</strong>. The access level needed to view this page is #{@page.level}, your access level is currently #{current_user.level}."
    else
      message = "You are unable to view the page: <strong>#{page_title}</strong>. The access level needed to view this page is #{@page.level}. You are currently not logged in."
    end
    authorize! :edit, @page, :message => message.html_safe

    @editors = []
    @editors = Person.where(role: ['editor', 'admin', 'super_admin'])
    @editors += Person.where(role: nil)


    if @page.owner_type == 'Group' && !@group
      redirect_to edit_polymorphic_path([@page.owner, @page])
    else
      respond_to do |format|
        format.html
      end
    end  
    # redirect_to "/editor" + page_path(page)
  end

  def update
    page = Page.find(params[:id])
    page_title = strip_tags page.title
    message = "You are unable to update the page: <strong>#{page_title}</strong> at this time."
    authorize! :edit, page, :message => message.html_safe
    
    if params[:content]
      page.title = params[:content][:page_title][:value]
      page.title = "Untitled" if page.title == "<br>" || page.title.blank?
      page.body = params[:content][:page_body][:value]
      page.header_picture = params[:content][:pages_header_image][:value] if params[:content][:pages_header_image]
      page.author ||= current_user
      page.unlock
      page.save! 
      render text: ""
    else
      if params[:owner]
        if params[:owner] == ""
          page.owner = nil
        else
          page.owner = Group.find(params[:owner])
        end
        page.save
      end
      if params[:position]
        page.position = params[:position][0].to_i
      end
      page.unlock

      if params[:page][:stretch]
        page.pages_enabled = false
        page.articles_enabled = false
        page.discussions_enabled = false
        page.smart_lists_enabled = false
        page.save!
      end

      page.update_attributes(params[:page])
      redirect_to page_path(page)
    end

  end
  
  def publish
    @page = Page.find(params[:id])
    @page.published = params[:published]
    page_title = strip_tags @page.title
    message = "You do not have the access needed to publish the page: <strong>#{page_title}</strong> at this time. If you are interested in publishing this page, please let us know."
    authorize! :publish, @page, :message => message.html_safe

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

  def cancel
    @page = Page.find(params[:id])
    @page.unlock
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
    page_title = strip_tags page.title
    message = "You do not have the access needed to duplicate the page: <strong>#{page_title}</strong> at this time. If you are still interested in duplicating this page, please let us know."
    authorize! :create, @duplicate, :message => message.html_safe

    @duplicate.save 
    redirect_to page_path(@duplicate)
  end

  def reset_token
    @page = Page.find(params[:id])
    @page.generate_token(:viewing_token)
    page_title = strip_tags @page.title
    message = "You do not have the access needed to reset the token for the page: <strong>#{page_title}</strong> at this time. If you are still interested in reseting the token for this page, please let us know."
    authorize! :publish, @page, :message => message.html_safe

    @page.save 
    redirect_to page_path(@page)
  end
  
  def destroy
    @page = Page.find(params[:id])
    page_title = strip_tags @page.title
    message = "You do not have the access needed to destroy the page: <strong>#{page_title}</strong> at this time. If you are still interested in destroying this page, please let us know."
    authorize! :destroy, @page, :message => message.html_safe
    
    if @page.destroy
      if @group
        redirect_to @group
      else
        redirect_to draft_pages_path
      end
    else
      redirect_to page_path(@page)
    end
  end

  def lookup_group
    @group = Group.find(params[:group_id]) if params[:group_id]

    if @group
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
    (@group) ? 'group' : 'page' 
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
