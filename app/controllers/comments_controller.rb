class CommentsController < ApplicationController
  
  before_filter :require_user
  before_filter :require_admin, :except => [:index, :show, :new, :create]
  # GET /comments
  # GET /comments.json
  def index
    @commentable = find_commentable  
    @comments = @commentable.comments 

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @comments }
    end
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
    @commentable = find_commentable  
    @comment = Comment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @comment }
    end
  end

  # GET /comments/new
  # GET /comments/new.json
  def new
    @comment = Comment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @comment }
    end
  end

  # GET /comments/1/edit
  def edit
    @commentable = find_commentable  
    @comment = Comment.find(params[:id])
  end

  # POST /comments
  # POST /comments.json
  def create
    @commentable = find_commentable  
    @comment = @commentable.comments.build(params[:comment])  
    @comment.author = current_user
  
    respond_to do |format|
      if @comment.save
        format.html { redirect_to @commentable, :flash => { :success => 'Comment was successfully sent.'} }
        format.json { render json: @comment, status: :created, location: @comment }
      else
        format.html { render action: "new" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.json
  def update
    @comment = Comment.find(params[:id])
    @comment.author = current_user
    
    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.html { redirect_to @comment, notice: 'Comment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @commentable = find_commentable  
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to @commentable }
      format.json { head :no_content }
    end
  end
  
  private
  def find_commentable  
    params.each do |name, value|  
      if name =~ /(.+)_id$/  
        return $1.classify.constantize.find(value)  
      end  
    end  
    nil  
  end  
end
