class VacationRangesController < ApplicationController
  unloadable
  before_filter :require_vacation_manager

  helper :sort
  include SortHelper

  # GET /vacation_ranges/
  def index
  
    sort_init 'start_date', 'desc'
    sort_update %w(start_date end_date)
    
    @limit = per_page_option
    
    scope = VacationRange.time_period(params[:time_period_start], :start_date).
      time_period(params[:time_period_end], :end_date).
      for_vacation_status(params[:vacation_status_id])
    
    @vacation_ranges_count = scope.count
    @vacation_range_pages = Paginator.new self, @vacation_ranges_count, @limit, params[:page]
    @offset ||= @vacation_range_pages.current.offset
    @vacation_ranges =  scope.find  :all,
                                  :order => sort_clause,
                                  :limit  =>  @limit,
                                  :offset =>  @offset
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
