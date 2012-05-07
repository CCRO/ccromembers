class Blog::PostsController < ApplicationController
  
  layout 'blog'
  
  def index
    @posts = Post.all.reverse
  end
  
  def show
    @post = Post.find(params[:id])
  end
  
  def new
    @post = Post.new
  end
  
  def create
    @post = Post.new(params[:post])
    
    @post.body = "This is the content of your new blog post."
    @post.author = current_user
    
    if @post.save!
      redirect_to blog_post_path(@post)
    else
      render 'new'
    end
  end
  
  def mercury_update
    post = Post.find(params[:id])
    post.title = params[:content][:post_title][:value]
    post.body = params[:content][:post_body][:value]
    post.save!
    render text: ""
  end
  
end
