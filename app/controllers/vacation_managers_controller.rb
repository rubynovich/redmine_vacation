class VacationManagersController < ApplicationController
  unloadable
  layout 'admin'

  before_filter :require_admin

  def index
    @vacation_managers = VacationManager.all.
      select(&:user).
      sort_by(&:user)
  end

  def create
    users = User.find_all_by_id(params[:user_ids])
    users.each do |user|
      VacationManager.create(:user_id => user.id)
    end
    @vacation_managers = VacationManager.all
#    redirect_to :action => 'index'
  end

  def destroy
    VacationManager.find(params[:id]).destroy if request.delete?
    @vacation_managers = VacationManager.all
#    redirect_to :action => 'index'
  end
end
