class MembershipsController < ApplicationController

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

  def destroy
    render :nothing => true
  end
end