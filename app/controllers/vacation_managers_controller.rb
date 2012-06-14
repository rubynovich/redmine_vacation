class VacationManagersController < ApplicationController
  unloadable
  layout 'admin'

  before_filter :require_admin

  def index
    @vacation_managers = VacationManager.all
  end
    
  def create
    users = User.find_all_by_id(params[:user_ids])
    users.each do |user|
      VacationManager.create(:user_id => user.id)
    end if request.post?
    respond_to do |format|
      format.html { redirect_to :controller => 'vacation_managers', :action => 'index'}
      format.js {
        render(:update) {|page|
          page.replace_html "content-users", :partial => 'users'
          users.each {|user| page.visual_effect(:highlight, "user-#{user.id}") }
        }
      }
    end
  end

  def destroy
    VacationManager.find(params[:id]).destroy if request.delete?
    @vacation_managers = VacationManager.all
    redirect_to :controller => 'vacation_managers', :action => 'index'
  end    
end

