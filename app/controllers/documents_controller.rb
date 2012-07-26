class DocumentsController < ApplicationController
  
  layout 'documents', :except => 'show'
  layout 'doc_viewer', :only => 'show'
  
  before_filter :require_user, :except => 'show'
  # GET /documents
  # GET /documents.json
  def index
    if current_user.admin?
      @documents = Document.accessible_by(current_ability)
    else
      @documents = Document.published.accessible_by(current_ability)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @documents }
      format.xml { render xml: @documents }
    end
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
    if params['token']
      @document = Document.find_by_viewing_token(params[:token])
    else 
      @document = Document.find(params[:id])
      authorize! :read, @document
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @document, :options => {:except => [:body], :methods => [:preview]} }
      format.xml { render xml: @document, :options => {:except => [:body], :methods => [:preview]} }
      
    end
  end
  
  # GET /documents/new
  # GET /documents/new.json
  def new
    @document = Document.new
    @document.format = 'markdown'
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @document }
    end
  end

  # GET /documents/1/edit
  def edit
    @document = Document.find(params[:id])
  end

  # POST /documents
  # POST /documents.json
  def create
    @document = Document.new(params[:document])
    @document.owner ||= default_company
    @document.author = current_user

    respond_to do |format|
      if @document.save
        format.html { redirect_to @document, :flash => { :success => 'Document was successfully created.'} }
        format.json { render json: @document, status: :created, location: @document }
      else
        format.html { render action: "new" }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /documents/1
  # PUT /documents/1.json
  def update
    @document = Document.find(params[:id])

    respond_to do |format|
      if @document.update_attributes(params[:document])
        format.html { redirect_to @document, :flash => { :success => 'Document was successfully updated.' } }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  def mercury_update
    document = Document.find(params[:id])
    document.title = params[:content][:document_title][:value]
    document.body = params[:content][:document_body][:value]
    document.save!
    render text: ""
  end
  
  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    @document = Document.find(params[:id])
    @document.destroy

    respond_to do |format|
      format.html { redirect_to documents_url }
      format.json { head :no_content }
    end
  end
end
