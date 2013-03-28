class PostsController < ApplicationController
  
  include ActionView::Helpers::TextHelper

  before_filter :lookup_group

  layout :conditional_layout

  def index
    if params[:filter] 
      if params[:filter] == 'drafts'
        authorize! :create, Post
        @posts = Post.where(:published => false).order('updated_at DESC')
      end
      if params[:filter] == 'my_drafts'
        authorize! :create, Post
        @posts = Post.where(:published => false, author_id: current_user).order('updated_at DESC')
      end
      if params[:filter] == 'archive'
        authorize! :create, Post
        @posts = Version.where(item_type: "Post", event: "destroy").map { |v| v.reify }.reverse.uniq
      end
      if params[:filter] == 'summit'
        @posts = Post.where(published: true).tagged_with("summit")
      end
    end

    if params[:tag_name]
      @posts = Post.where(published: true).tagged_with(params[:tag_name])
    end
    
    @posts ||= Post.where(:published => true).order('published_at DESC')

    if params[:page]
      @page = Page.find(params[:page])
    end

    if @group
      @posts = @group.posts.order('updated_at DESC')

      message = "You are unable to view news and updates for the working group: <strong>#{@group.name}</strong>. If you are still interested in viewing news and updates for this group, please let us know."
      authorize! :read, @group, :message => message.html_safe
    end

    @groups = Group.where("overview_page IS NOT NULL").order("created_at asc")
    @my_groups = []
    @other_groups = []
    @groups.each do |group| 
      if group.people.include? current_user
        @my_groups << group
      else
        @other_groups << group
      end
    end


    
    respond_to do |format|
      format.html
      format.rss { render :layout => false }
      format.atom { render :layout => false }
    end
  end
  
  def draft
    @posts = Post.where(:published => false).order('updated_at DESC')
    @my_posts = Post.where(published: false, author_id: current_user).order('updated_at DESC')
  end
  
  def show
    @editors = []
    @editors = Person.where(role: ['editor', 'admin', 'super_admin'])
    @editors += Person.where(role: nil)

    if params['token']
      @post = Post.find_by_viewing_token(params[:token])
    else 
      @post = Post.find(params[:id])
      @tag = @post.tags.pluck(:name).to_sentence if @post.tags.pluck(:name).present?
      @all_tags = all_tags
      @category = Post.tagged_with(@tag)
      @commentable = @post

      post_title = strip_tags @post.title
      if current_user 
        message = "You are unable to view the post: <strong>#{post_title}</strong>. The access level needed to view this post is #{@post.level}, your access level is currently #{current_user.level}."
      else
        message = "You are unable to view the post: <strong>#{post_title}</strong>. The access level needed to view this post is #{@post.level}. You are currently not logged in."
      end
      authorize! :read, @post, :message => message.html_safe
    end

    if params[:page]
      @page = Page.find(params[:page])
    end

    if @post.published 
      impressionist(@post)
    end

    if @group
      @article = @post
    end
    
    @groups = Group.where("overview_page IS NOT NULL").order("created_at asc")
    @my_groups = []
    @other_groups = []
    @groups.each do |group| 
      if group.people.include? current_user
        @my_groups << group
      else
        @other_groups << group
      end
    end

    respond_to do |format|
      format.html
      format.pdf { doc_raptor_send }
    end
  end

  def share
    post = Post.find(params[:id])
    post_title = strip_tags post.title
    if current_user
      message = "You are unable to share the post: <strong>#{post_title}</strong>. The access level needed to share this post is #{post.level}, your access level is currently #{current_user.level}."  
    else
      message = "You are unable to share the post: <strong>#{post_title}</strong>. The access level needed to share this post is #{post.level}. You are currently not logged in."
    end
    
    authorize! :read, post, :message => message.html_safe
    post.share_by_email(params[:email_list], params[:my_subject], params[:short_message], current_user)
    redirect_to post
  end

  
  def new
    @post = Post.new
    if params[:group_id]
      @owner = Group.find(params[:group_id])
    end
  end
  
  def create

    @post = Post.new(params[:post])
    
    @post.body = "This text is your preview text. It will be before the break.<br><br>[---MORE---]<br><br>This text is after the break. Put the MORE and its surronding characters where you want to end your post preview!"
    if params[:group_id]
      @post.owner = Group.find(params[:group_id]) 
    else
      @post.owner ||= current_user
    end
    @post.author = current_user
    @post.published = false
    @post.level ||= 'public'
    @post.generate_token(:viewing_token)
    
    if @post.owner_type == 'Group'
      post_title = strip_tags @post.title
      message = "You are unable to create the post: <strong>#{post_title}</strong> for this group."
      authorize! :create_in, @post.owner, :message => message.html_safe

    else
      post_title = strip_tags @post.title
      message = "You are unable to create the post: <strong>#{post_title}</strong>."
      authorize! :create, @post, :message => message.html_safe

    end
    
    if @post.save
      redirect_to polymorphic_path([@group, @post])
    else
      flash[:notice] = "Please give your new draft a title."
      redirect_to draft_posts_path
    end
  end
  
  def claim
    post = Post.find(params[:id])
    post_title = strip_tags post.title
    message = "You are unable to claim the post: <strong>#{post_title}</strong> at this time."
    authorize! :edit, post, :message => message.html_safe
    
    post.author = current_user
    post.save
    
    redirect_to post
  end
  
  def edit
    @editors = []
    @editors = Person.where(role: ['editor', 'admin', 'super_admin'])
    @editors += Person.where(role: nil)

    if params['token']
      @post = Post.find_by_viewing_token(params[:token])
    else 
      @post = Post.find(params[:id])
      @tag = @post.tags.pluck(:name).to_sentence if @post.tags.pluck(:name).present?
      @all_tags = all_tags
      @category = Post.tagged_with(@tag)
      @commentable = @post

      post_title = strip_tags @post.title
      if current_user 
        message = "You are unable to view the post: <strong>#{post_title}</strong>. The access level needed to view this post is #{@post.level}, your access level is currently #{current_user.level}."
      else
        message = "You are unable to view the post: <strong>#{post_title}</strong>. The access level needed to view this post is #{@post.level}. You are currently not logged in."
      end
      authorize! :read, @post, :message => message.html_safe
    end

    if params[:page]
      @page = Page.find(params[:page])
    end

    if @post.published 
      impressionist(@post)
    end

    if @group
      @article = @post
    end

    unless @post.locked?
      @post.lock(current_user)
      @post.save
    end

    render :edit
    # redirect_to "/editor" + polymorphic_path([@group, post])
  end

  def update
    post = Post.find(params[:id])
    post_title = strip_tags post.title

    message = "You are unable to update the post: <strong>#{post_title}</strong> at this time."
    authorize! :edit, post, :message => message.html_safe
    
    
    if params[:content]
      post.title = params[:content][:post_title][:value]
      post.title = "Untitled" if post.title == "<br>" || post.title.blank?
      post.body = params[:content][:post_body][:value]
      post.author ||= current_user
      post.unlock
      post.save! 
      render text: ""
    else
      post.unlock
      post.update_attributes(params[:post])
      redirect_to polymorphic_path([post.owner, post])
    end



  end
  
  def publish
    @post = Post.find(params[:id])
    @post.published = params[:published]
    post_title = strip_tags @post.title

    message = "You do not have the access needed to publish the post: <strong>#{post_title}</strong> at this time. If you are still interested in publishing this post, please let us know."
    authorize! :publish, @post, :message => message.html_safe

    @post.save 
    redirect_to polymorphic_path([@group, @post])
  end

  def restore
    @post = Version.where(item_type: 'Post', item_id: params[:id], event: 'destroy').last.reify
    @post.published = false
    @post.author = current_user
    @post.save!
    redirect_to post_path(@post)
  end

  def cancel
    @post = Post.find(params[:id])
    @post.unlock
    @post.save!
    redirect_to post_path(@post)
  end

  def duplicate
    post = Post.find(params[:id])
    @duplicate = Post.new(post.attributes)
    @duplicate.owner = current_user
    @duplicate.title += " Copy"
    @duplicate.generate_token
    @duplicate.published = false
    @duplicate.locked = nil
    @duplicate.locker_id = nil
    @duplicate.locked_at = nil
    @duplicate.tag_list = nil
    post_title = strip_tags post.title

    message = "You do not have the access needed to duplicate the post: <strong>#{post_title}</strong> at this time. If you are still interested in duplicating this post, please let us know."
    authorize! :create, @duplicate, :message => message.html_safe

    @duplicate.save 
    redirect_to post_path(@duplicate)
  end

  def reset_token
    @post = Post.find(params[:id])
    @post.generate_token(:viewing_token)
    post_title = strip_tags @post.title

    message = "You do not have the access needed to reset the token for the post: <strong>#{post_title}</strong> at this time. If you are still interested in reseting the token for this post, please let us know."
    authorize! :publish, @post, :message => message.html_safe

    @post.save 
    redirect_to post_path(@post)
  end
  
  def destroy
    @post = Post.find(params[:id])
    post_title = strip_tags @post.title
    
    message = "You do not have the access needed to destroy the post: <strong>#{post_title}</strong> at this time. If you are still interested in destroying this post, please let us know."
    authorize! :destroy, @post, :message => message.html_safe
    
    if @post.destroy
      if @group
        redirect_to @group
      else
        redirect_to root_path
      end

    else
      redirect_to post_path(@post)
    end
  end

  def lookup_group
     if params[:group_id]
      @group = Group.find(params[:group_id])
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
    (@group) ? 'group' : 'blog' 
  end

  def doc_raptor_send(options = { })
    default_options = { 
      :name             => "CCRO-" + @post.permalink,
      :document_type    => request.format.to_sym,
      :test             => ! Rails.env.production?,
      :strict           => false
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
