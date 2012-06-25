require_dependency 'issue'

module VacationIssuePatch
  def self.included(base)
    base.extend(ClassMethods)
    
    base.send(:include, InstanceMethods)
    
    base.class_eval do
      validate :assigned_to_on_vacation
      
      named_scope :on_vacation, lambda{ |vacation_range|
        { :conditions => ["(start_date BETWEEN :start_date AND :end_date) OR (due_date BETWEEN :start_date AND :end_date) OR ((start_date <= :start_date) AND (due_date >= :end_date))", {
          :start_date => vacation_range.start_date, 
          :end_date => vacation_range.end_date}]
        }
      }
      
      named_scope :with_author, lambda{ |user_id|
        {
          :conditions => {:author_id => user_id}
        }
      }
      
      named_scope :with_assigned_to, lambda{ |user_id|
        {
          :conditions => {:assigned_to_id => user_id}
        }
      }
    end

  end
    
  module ClassMethods
  end
  
  module InstanceMethods
    def assigned_to_on_vacation
      if vacation = Vacation.find_by_user_id(self.assigned_to_id)
        if on_vacation?(vacation_range = vacation.active_planned_vacation) ||
            on_vacation?(vacation_range = vacation.last_planned_vacation) ||
            on_vacation?(vacation_range = vacation.not_planned_vacation)
        
          errors.add :assigned_to_id, :on_vacation, 
            :from => vacation_range.start_date, 
            :to => vacation_range.end_date
        end
      end
    end
    
    def on_vacation?(vacation_range)
      vacation_range.present? && 
          vacation_range.in_range?(self.start_date, self.due_date)
    end
  end
end
