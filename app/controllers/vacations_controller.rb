class VacationsController < ApplicationController
  unloadable
  before_filter :require_vacation_manager
  
  helper :sort
  include SortHelper
  helper :vacations
  include VacationsHelper

  # GET /vacations/
  def index
    @limit = per_page_option
    
    scope = Vacation.like_name(params[:name])
    
    @vacations_count = scope.count
    @vacation_pages = Paginator.new self, @vacations_count, @limit, params[:page]
    @offset ||= @vacation_pages.current.offset
    @vacations =  scope.find( :all,
                              :joins => :user,
                              :order => "firstname, lastname",
                              :limit  =>  @limit,
                              :offset =>  @offset )
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
    sort_init 'start_date', 'desc'
    sort_update %w(start_date end_date vacation_status_id)
  
    @vacation = Vacation.find(params[:id])
    
    @limit = per_page_option
    
    @scope = VacationRange.for_user(@vacation.user_id)
    
    @vacation_ranges_count = @scope.count
    @vacation_range_pages = Paginator.new self, @vacation_ranges_count, @limit, params[:page]
    @offset ||= @vacation_range_pages.current.offset
    @vacation_ranges =  @scope.find  :all,
                                  :order => sort_clause,
                                  :limit  =>  @limit,
                                  :offset =>  @offset
    respond_to do |format|
      format.html{ render :action => :show}
      format.csv{ send_data(show_to_csv, :type => 'text/csv; header=present', :filename => Date.today.strftime("vacations_%Y-%m-%d_#{@vacation.user.login}.csv")) }
    end
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
