class Vacation < ActiveRecord::Base
  unloadable
  
  validates_presence_of :user_id
  validates_uniqueness_of :user_id  
  
  belongs_to :user
  belongs_to :last_planned_vacation, 
    :class_name => 'VacationRange', 
    :foreign_key => 'last_planned_vacation_id'
  belongs_to :active_planned_vacation, 
    :class_name => 'VacationRange', 
    :foreign_key => 'active_planned_vacation_id'
  belongs_to :not_planned_vacation, 
    :class_name => 'VacationRange', 
    :foreign_key => 'not_planned_vacation_id'
end
