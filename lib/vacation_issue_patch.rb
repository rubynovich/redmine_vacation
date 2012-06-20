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
        if vacation.active_planned_vacation.present?
          if vacation.active_planned_vacation.include?(self.start_date) ||
            vacation.active_planned_vacation.include?(self.due_date)
            errors.add :assigned_to_id, :is_vacation
          end
        elsif vacation.last_planned_vacation.present?
          if vacation.last_planned_vacation.include?(self.start_date) ||
            vacation.last_planned_vacation.include?(self.due_date)
            errors.add :assigned_to_id, :is_vacation
          end
        elsif vacation.not_planned_vacation.present?
          if vacation.not_planned_vacation.include?(self.start_date) ||
            vacation.not_planned_vacation.include?(self.due_date)
            errors.add :assigned_to_id, :is_vacation
          end        
        end
      end
    end
  end
end
