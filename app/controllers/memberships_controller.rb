class MembershipsController < ApplicationController

  before_filter :lookup_group

  layout 'group'

  def index
    @people = @group.people
    @co_chairs = @group.memberships.where(fuction: 'chair').map { |membership| membership.person }
    @coordinators = @group.memberships.where(fuction: 'coordinator').map { |membership| membership.person }

    @participants = @people - @co_chairs - @coordinators
    authorize! :read, @group

    if params[:format] = 'csv'
      csv_data = CSV.generate() do |csv|
        csv << ['name', 'email', 'company', 'level']
        @people.each do |person|
          csv << [person.name, person.email, person.company_name, person.level] # person.attributes.values_at(*column_names)
        end
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.csv { send_data csv_data }
    end
  end

  def create
    render :nothing => true
  end

  def toggle
    if params[:toggle]
      Membership.create(:group_id => params[:group_id], :person_id => params[:person_id])
      render :nothing => true
    elsif params[:membership]
      Membership.create(:group_id => params[:membership][:group_id], :person_id => params[:membership][:person_id])
      redirect_to edit_group_path(Group.find(params[:membership][:group_id]))
    else
      Membership.find_by_group_id_and_person_id(params[:group_id], params[:person_id]).destroy
      render :nothing => true
    end
    
   end

  def update
    @membership = Membership.find(params[:id])

    @membership.update_attributes(params[:membership])

    authorize! :manage, @group

    @membership.save

    respond_to do |format|
      if @membership.save
        format.html { redirect_to group_path(@group), notice: 'Group was successfully updated.' }
        format.json { head :no_content }
        format.js { render nothing: true, status: 200 }
      else
        format.html { render action: "edit" }
        format.json { render json: @membership.errors, status: :unprocessable_entity }
      end
    end


  end

  def destroy
    render :nothing => true
  end

  def lookup_group
    @group = Group.find(params[:group_id]) if params[:group_id]

    if @group
      @pages = @group.pages
      @attachments = @group.attachments
      @messages = @group.messages
      @group_document = @group.documents
      @smart_list = @group.people

      if current_user && @group.leadership.include?(current_user)
        @total_articles = @group.posts
        @articles = @total_articles.limit(3)
      else
        @total_articles = @group.posts.where(hidden: false)
        @articles = @total_articles.limit(3)
      end
    end

  end

end