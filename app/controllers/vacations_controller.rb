class VacationsController < ApplicationController
  unloadable
  before_filter :require_vacation_manager

  # GET /vacations/
  def index
    @vacation_pages, @vacations = paginate :vacations, :per_page => 25, :order => "user_id"
    render :action => "index", :layout => false if request.xhr?
  end

  # GET /vacations/new
  def new
    @vacation = Vacation.new
  end
  
  # POST /vacations
  def create
    @vacation = Vacation.new(params[:vacation])
    if request.post? && @vacation.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  # GET /vacations/1/edit
  def edit
    @vacation = Vacation.find(params[:id])
  end
  
  # GET /vacations/1
  def show
    @vacation = Vacation.find(params[:id])
  end  
  

  # POST /vacations
  def create
    @vacation = Vacation.new(params[:vacation])
    if request.post? && @vacation.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  # PUT /vacations/1
  def update
    @vacation = Vacation.find(params[:id])

    respond_to do |format|
      if @vacation.update_attributes(params[:vacation])
        flash[:notice] = l(:notice_successful_update)
        format.html { redirect_to(vacations_path) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  # DELETE /vacations/1
  def destroy
    Vacation.find(params[:id]).destroy
    redirect_to :action => 'index'
  rescue
    flash[:error] = l(:error_unable_delete_vacation)
    redirect_to :action => 'index'
  end  
  
  private
    def require_vacation_manager
      (render_403; return false) unless User.current.is_vacation_manager?
    end
end
