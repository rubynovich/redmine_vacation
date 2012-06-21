require_dependency 'issue'

module VacationIssuePatch
  def self.included(base)
    base.extend(ClassMethods)
    
    base.send(:include, InstanceMethods)
    
    base.class_eval do
      validate :not_vacation
    end

  end
    
  module ClassMethods
  end
  
  module InstanceMethods
    def not_vacation
      if vacation = Vacation.find_by_user_id(self.assigned_to_id)
        check_vacation_dates vacation.active_planned_vacation
        check_vacation_dates vacation.last_planned_vacation
        check_vacation_dates vacation.not_planned_vacation
      end
    end
    
    def check_vacation_dates(vacation_range)
      if vacation_range.present? && 
          vacation_range.in_range?(self.start_date, self.due_date)
        errors.add :assigned_to_id, :is_vacation, :from => vacation_range.start_date, :to => vacation_range.end_date
      end
    end
  end
end
