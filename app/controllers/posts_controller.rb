class PostsController < ApplicationController
  
  layout 'blog'
  
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
    end
    
    @posts ||= Post.where(:published => true).order('published_at DESC')
    
    
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
    @editors = Person.where(role: ['editor', 'admin', 'super_admin'])
    if params['token']
      @post = Post.find_by_viewing_token(params[:token])
    else 
      @post = Post.find(params[:id])
      @commentable = @post
      authorize! :read, @post
    end
  end

  def share
    post = Post.find(params[:id])
    authorize! :read, post
    post.share_by_email(params[:email_list], current_user)
    redirect_to post
  end

  
  def new
    @post = Post.new
  end
  
  def create

    @post = Post.new(params[:post])
    
    @post.body = "This text is your preview text. It will be before the break.<br><br>[---MORE---]<br><br>This text is after the break. Put the MORE and its surronding characters where you want to end your post preview!"
    @post.owner = current_user
    @post.author = current_user
    @post.published = false
    @post.level ||= 'public'
    @post.generate_token(:viewing_token)
    
    authorize! :create, @post
    
    if @post.save
      redirect_to post_path(@post)
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
    redirect_to "/editor" + post_path(post)
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
      render text: ""
    end

  end
  
  def publish
    @post = Post.find(params[:id])
    @post.published = params[:published]

    authorize! :publish, @post

    @post.save 
    redirect_to post_path(@post)
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
      redirect_to root_path
    else
      redirect_to post_path(@post)
    end
  end
end