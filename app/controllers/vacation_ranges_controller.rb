class VacationRangesController < ApplicationController
  unloadable
  before_filter :require_vacation_manager
  before_filter :find_vacation_range, only: [:edit, :show, :update, :destroy]
  before_filter :new_vacation_range, only: [:new, :create]

  helper :sort
  include SortHelper
  helper :vacation_ranges
  include VacationRangesHelper

  # GET /vacation_ranges/
  def index
    sort_init 'start_date', 'desc'
    sort_update %w(start_date end_date)

    @limit = per_page_option

    @scope = VacationRange.time_period(params[:time_period_start], :start_date).
      time_period(params[:time_period_end], :end_date).
      for_vacation_status(params[:vacation_status_id]).
      like_username(params[:name])

    @vacation_ranges_count = @scope.count
    @vacation_range_pages = Paginator.new self, @vacation_ranges_count, @limit, params[:page]
    @offset ||= @vacation_range_pages.current.offset
    @vacation_ranges =  @scope.find  :all,
                                  :order => sort_clause,
                                  :limit  =>  @limit,
                                  :offset =>  @offset
    respond_to do |format|
      format.html{ render :action => :index }
      format.csv{ send_data(index_to_csv, :type => 'text/csv; header=present', :filename => Date.today.strftime("vacation_ranges_%Y-%m-%d.csv")) }
    end
  end

  # GET /vacation_ranges/new
  def new
    @vacation_range.vacation_status = VacationStatus.default
  end

  # POST /vacation_ranges
  def create
    if @vacation_range.save
      flash[:notice] = l(:notice_successful_create)
      redirect_back_or_default action: 'index'
    else
      render action: 'new'
    end
  end

  # PUT /vacation_ranges/1
  def update
    if @vacation_range.update_attributes(params[:vacation_range])
      flash[:notice] = l(:notice_successful_update)
      redirect_back_or_default action: 'index'
    else
      render action: 'edit'
    end
  end

  # DELETE /vacation_ranges/1
  def destroy
    @vacation_range.destroy
    redirect_to action: 'index'
  rescue
    flash[:error] = l(:error_unable_delete_vacation_range)
    redirect_to action: 'index'
  end

  private
    def find_vacation_range
      @vacation_range = VacationRange.find(params[:id])
    end

    def new_vacation_range
      @vacation_range = VacationRange.new(params[:vacation_range])
    end

    def require_vacation_manager
      (render_403; return false) unless User.current.is_vacation_manager?
    end
end
