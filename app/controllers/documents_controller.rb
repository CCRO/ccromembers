class DocumentsController < ApplicationController
  
  layout 'documents', :except => 'show'
  layout 'doc_viewer', :only => 'show'
  
  before_filter :require_user, :except => 'show'
  # GET /documents
  # GET /documents.json
  def index
    @documents = Document.all.delete_if { |document| cannot? :read, document }

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

    # @document.update_viewer_uuid!

    # session_key = Crocodoc::Session.create(@document.viewer_uuid, {
    #     'is_editable' => true,
    #     'user' => {
    #         'id' => current_user.id,
    #         'name' => current_user.name
    #     },
    #     'filter' => 'all',
    #     'is_admin' => true,
    #     'is_downloadable' => true,
    #     'is_copyprotected' => false,
    #     'is_demo' => false,
    #     'sidebar' => 'visible'
    # })

    respond_to do |format|
      format.html #{ redirect_to "https://crocodoc.com/view/" + session_key } # show.html.erb
      format.pdf { doc_raptor_send }
      format.json { render json: @document, :options => {:except => [:body], :methods => [:preview]} }
      format.xml { render xml: @document, :options => {:except => [:body], :methods => [:preview]} } 
    end
  end
  
  # GET /documents/new
  # GET /documents/new.json
  def new
    @document = Document.new
    # @document.format = 'markdown'
    if params[:group_id]
      @owner = Group.find(params[:group_id])
    end
    
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
    @document.generate_token
    @document.archived = false
    if params[:group_id]
      @document.owner = Group.find(params[:group_id]) 
    else
      @document.owner ||= default_company
    end
    @document.author = current_user

    respond_to do |format|
      if @document.save
        format.html { redirect_to document_path(@document), :flash => { :success => 'Document was successfully created.'} }
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

    def doc_raptor_send(options = { })
    default_options = { 
      :name             => "CCRO-" + @document.permalink,
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
