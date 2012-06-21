class Blog::PostsController < ApplicationController
  
  layout 'blog'
  
  def index
    @posts = Post.where(:published => true)
    
    respond_to do |format|
      format.html
      format.rss { render :layout => false }
      format.atom { render :layout => false }
    end
  end
  
  def draft
    @posts = Post.where(:published => false)
  end
  
  def show
    @post = Post.find(params[:id])
    
    authorize! :read, @post
  end
  
  def new
    @post = Post.new
  end
  
  def create
    @post = Post.new(params[:post])
    
    @post.body = "This is the content of your new blog post."
    @post.owner = current_user
    @post.published = false
    @post.level ||= 'public'
    
    authorize! :create, @post
    
    if @post.save
      redirect_to blog_post_path(@post)
    else
      flash[:notice] = "Please give your new draft a title."
      redirect_to draft_blog_posts_path
    end
  end
  
  def claim
    post = Post.find(params[:id])
    
    authorize! :edit, post
    
    post.author = current_user
    post.save
    
    redirect_to post
  end
  
  def update
    post = Post.find(params[:id])

    authorize! :edit, post
    
    post.title = params[:content][:post_title][:value]
    post.title = "Untitled" if post.title == "<br>" || post.title.blank?
    post.body = params[:content][:post_body][:value]
    post.author ||= current_user
    post.save! 
    render text: ""
  end
  
  def publish
    @post = Post.find(params[:id])
    @post.published = params[:published]
    @post.save 
    redirect_to blog_post_path(@post)
  end
  
  def destroy
    @post = Post.find(params[:id])
    
    authorize! :destroy, @post
    
    if @post.destroy
      redirect_to root_path
    else
      redirect_to blog_post_path(@post)
    end
  end
end
