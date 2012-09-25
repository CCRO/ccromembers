class PollsController < ApplicationController
  # GET /polls
  # GET /polls.json
  before_filter :require_user
  layout 'polls'
  has_mobile_fu
  #before_filter :force_mobile_format
  
  def index
    @polls = Poll.all
    authorize! :create, Polls

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @polls }
    end
  end

  # GET /polls/1
  # GET /polls/1.json
  def show
    @poll = Poll.find(params[:id])
    authorize! :read, Poll

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @poll }
    end
  end

  def active
    @poll = Poll.where(active: true).last
    
    if @poll
      @impression = Impression.where(impressionable_type: 'Poll', user_id: current_user.id, impressionable_id: @poll.id).last
    end
    
    authorize! :read, Poll

    respond_to do |format|
      format.mobile
      format.html # show.html.erb
      format.json { render json: @poll }
    end
  end

  def report
    @poll = Poll.find(params[:id])
    @results = ["a","b","c","d"].zip(["a","b","c","d"].map { |r| Impression.where(impressionable_type: 'Poll', impressionable_id: @poll.id, message: r).count })

    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', 'Option' )
    data_table.new_column('number', 'count')
    data_table.add_rows(@results)

    option = { width: 1600, height: 1200, title: '', is3D: true, backgroundColor: '#EFEFEF', slices: [{color: '#305D9A'}, {color: '#6C3'}, {color: 'black'}, {color: 'red'}]}
    @chart = GoogleVisualr::Interactive::PieChart.new(data_table, option)

    authorize! :create, Poll

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @poll }
    end
  end

  # GET /polls/new
  # GET /polls/new.json
  def new
    @poll = Poll.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @poll }
    end
  end

  def new_for_session
    @poll = Poll.new
    @polling_session = PollingSession.find(params[:polling_session])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @poll }
    end
  end

  # GET /polls/1/edit
  def edit
    @poll = Poll.find(params[:id])
  end

  # POST /polls
  # POST /polls.json
  def create
    @poll = Poll.new(params[:poll])

    respond_to do |format|
      if @poll.save
        format.html { redirect_to @poll, notice: 'Poll was successfully created. It has not been activated' }
        format.json { render json: @poll, status: :created, location: @poll }
      else
        format.html { render action: "new" }
        format.json { render json: @poll.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /polls/1
  # PUT /polls/1.json
  def update
    @poll = Poll.find(params[:id])

    respond_to do |format|
      if @poll.update_attributes(params[:poll])
        format.html { redirect_to @poll, notice: 'Poll was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @poll.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /polls/1
  # DELETE /polls/1.json
  def destroy
    @poll = Poll.find(params[:id])
    @poll.destroy

    redirect_to @poll.polling_session
  end

  def deactivate
    @poll = Poll.find(params[:id])
    @poll.active = false
    @poll.save

    redirect_to @poll.polling_session
  end

  def activate
    @poll = Poll.find(params[:id])
    deactivate_me = Poll.where(active: true)
    deactivate_me.each do |d|
      d.active = false
      d.save
    end
    @poll.active = true
    @poll.save

    redirect_to @poll.polling_session
  end


  def pick_a
    @poll = Poll.find(params[:id])
    impressionist(@poll, "a", :unique => [:impressionable_type, :impressionable_id, :user_id])

    redirect_to active_polls_path, notice: 'Thanks for participating.'
  end

  def pick_b
    @poll = Poll.find(params[:id])
    impressionist(@poll, "b", :unique => [:impressionable_type, :impressionable_id, :user_id])

    
    redirect_to active_polls_path, notice: 'Thanks for participating.'
  end

  def pick_c
    @poll = Poll.find(params[:id])
    impressionist(@poll, "c", :unique => [:impressionable_type, :impressionable_id, :user_id])

    
    redirect_to active_polls_path, notice: 'Thanks for participating.'
  end

  def pick_d
    @poll = Poll.find(params[:id])
    impressionist(@poll, "d", :unique => [:impressionable_type, :impressionable_id, :user_id])

    
    redirect_to active_polls_path, notice: 'Thanks for participating.'
  end

end
