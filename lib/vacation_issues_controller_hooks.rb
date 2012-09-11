module RedmineVacation
  class Hook < Redmine::Hook::ViewListener
    def controller_issues_edit_after_save(context = {})
      assigned_to_id = context[:issue].assigned_to_id
      if assigned_to_id && 
        (vacation = Vacation.find_by_user_id(assigned_to_id))&&
        (vacation_range = vacation.active_planned_vacation)&&
        (vacation_range.start_date > Date.today)        
        
        flash[:warning] = t(:vacation_warning_flash,
          :name => User.find(assigned_to_id).name,
          :from => vacation_range.start_date.strftime("%d.%m.%Y"), 
          :to => vacation_range.end_date.strftime("%d.%m.%Y"))
      end      
    end
    
    alias_method :controller_issues_new_after_save, :controller_issues_edit_after_save
  end
end
