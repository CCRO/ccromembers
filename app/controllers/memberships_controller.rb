class MembershipsController < ApplicationController

  before_filter :lookup_group

  layout 'group'

  def index
    @people = @group.people
    @co_chairs = @group.memberships.where(fuction: 'chair').map { |membership| membership.person }
    @coordinators = @group.memberships.where(fuction: 'coordinator').map { |membership| membership.person }

    @participants = @people - @co_chairs - @coordinators
    authorize! :read, @group
  end

  def create
    render :nothing => true
  end

  def toggle
    if params[:toggle]
      Membership.create(:group_id => params[:group_id], :person_id => params[:person_id])
    else
      Membership.find_by_group_id_and_person_id(params[:group_id], params[:person_id]).destroy
    end
    render :nothing => true
   end

  def update
    @membership = Membership.find(params[:id])

    @membership.update_attributes(params[:membership])

    authorize! :manage, @group

    @membership.save
  end

  def destroy
    render :nothing => true
  end

  def lookup_group
    @group = Group.find(params[:group_id]) if params[:group_id]

    if @group
      @pages = @group.pages
      @articles = @group.posts
      @messages = @group.messages
      @group_document = @group.documents
      @smart_list = @group.people
    end

  end

end