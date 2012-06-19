class VacationRangesController < ApplicationController
  unloadable
  before_filter :require_vacation_manager

  # GET /vacation_ranges/
  def index
    @vacation_range_pages, @vacation_ranges = paginate :vacation_ranges, :per_page => 25, :order => "user_id"
    render :action => "index", :layout => false if request.xhr?
  end

  # GET /vacation_ranges/new
  def new
    @vacation_range = VacationRange.new(:vacation_status => VacationStatus.default)
  end
  
  # POST /vacation_ranges
  def create
    @vacation_range = VacationRange.new(params[:vacation_range])
    if request.post? && @vacation_range.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  # GET /vacation_ranges/1/edit
  def edit
    @vacation_range = VacationRange.find(params[:id])
  end
  
  # GET /vacation_ranges/1
  def show
    @vacation_range = VacationRange.find(params[:id])
  end  
  

  # POST /vacation_ranges
  def create
    @vacation_range = VacationRange.new(params[:vacation_range])
    if request.post? && @vacation_range.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  # PUT /vacation_ranges/1
  def update
    @vacation_range = VacationRange.find(params[:id])

    respond_to do |format|
      if @vacation_range.update_attributes(params[:vacation_range])
        flash[:notice] = l(:notice_successful_update)
        format.html { redirect_to(vacation_ranges_path) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  # DELETE /vacation_ranges/1
  def destroy
    VacationRange.find(params[:id]).destroy
    redirect_to :action => 'index'
  rescue
    flash[:error] = l(:error_unable_delete_vacation_range)
    redirect_to :action => 'index'
  end  
  
  private
    def require_vacation_manager
      (render_403; return false) unless User.current.is_vacation_manager?
    end
end
