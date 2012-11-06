class PostsController < ApplicationController
  
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
      authorize! :read, @group 
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
      authorize! :read, @post
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

    respond_to do |format|
      format.html
      format.pdf { doc_raptor_send }
    end
  end

  def share
    post = Post.find(params[:id])
    authorize! :read, post
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
      authorize! :create_in, @post.owner
    else
      authorize! :create, @post
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
    
    authorize! :edit, post
    
    post.author = current_user
    post.save
    
    redirect_to post
  end
  
  def edit
    post = Post.find(params[:id])
    unless post.locked?
      post.lock(current_user)
      post.save
    end
    redirect_to "/editor" + polymorphic_path([@group, post])
  end

  def update
    post = Post.find(params[:id])

    authorize! :edit, post
    
    if params[:content]
      post.title = params[:content][:post_title][:value]
      post.title = "Untitled" if post.title == "<br>" || post.title.blank?
      post.body = params[:content][:post_body][:value]
      post.author ||= current_user
      post.unlock
      post.save! 
      render text: ""
    else
      post.update_attributes(params[:post])
      redirect_to polymorphic_path([post.owner, post])
    end

  end
  
  def publish
    @post = Post.find(params[:id])
    @post.published = params[:published]

    authorize! :publish, @post

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

    authorize! :create, @duplicate

    @duplicate.save 
    redirect_to post_path(@duplicate)
  end

  def reset_token
    @post = Post.find(params[:id])
    @post.generate_token(:viewing_token)

    authorize! :publish, @post

    @post.save 
    redirect_to post_path(@post)
  end
  
  def destroy
    @post = Post.find(params[:id])
    
    authorize! :destroy, @post
    
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
      @pages = @group.pages
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
