class Blog::PostsController < ApplicationController
  
  layout 'blog'
  
  def index
    @posts = Post.all
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
    @post.author = current_user
    
    authorize! :create, @post
    if @post.save!
      redirect_to blog_post_path(@post)
    else
      render 'new'
    end
  end
  
  def mercury_update
    post = Post.find(params[:id])

    authorize! :edit, post
    
    post.title = params[:content][:post_title][:value]
    post.body = params[:content][:post_body][:value]
    post.author ||= current_user
    post.save!
    render text: ""
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
