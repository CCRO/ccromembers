class PollingSessionsController < ApplicationController
  # GET /polling_sessions
  # GET /polling_sessions.json

  layout 'polls'

  def index
    @polling_sessions = PollingSession.all
    authorize! :create, PollingSession

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @polling_sessions }
    end
  end

  # GET /polling_sessions/1
  # GET /polling_sessions/1.json
  def show
    @polling_session = PollingSession.find(params[:id])
    @polls = @polling_session.polls
    authorize! :read, PollingSession

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @polling_session }
    end
  end

  def report
    @polling_session = PollingSession.find(params[:id])
    @poll = @polling_session.polls

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @polling_session }
    end
  end

  # GET /polling_sessions/new
  # GET /polling_sessions/new.json
  def new
    @polling_session = PollingSession.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @polling_session }
    end
  end

  # GET /polling_sessions/1/edit
  def edit
    @polling_session = PollingSession.find(params[:id])
  end

  # POST /polling_sessions
  # POST /polling_sessions.json
  def create
    @polling_session = PollingSession.new(params[:polling_session])

    respond_to do |format|
      if @polling_session.save
        format.html { redirect_to @polling_session, notice: 'Polling session was successfully created.' }
        format.json { render json: @polling_session, status: :created, location: @polling_session }
      else
        format.html { render action: "new" }
        format.json { render json: @polling_session.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /polling_sessions/1
  # PUT /polling_sessions/1.json
  def update
    @polling_session = PollingSession.find(params[:id])

    respond_to do |format|
      if @polling_session.update_attributes(params[:polling_session])
        format.html { redirect_to @polling_session, notice: 'Polling session was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @polling_session.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /polling_sessions/1
  # DELETE /polling_sessions/1.json
  def destroy
    @polling_session = PollingSession.find(params[:id])
    @polling_session.destroy

    respond_to do |format|
      format.html { redirect_to polling_sessions_url }
      format.json { head :no_content }
    end
  end
end
