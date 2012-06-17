class VacationRange < ActiveRecord::Base
  unloadable
  
  belongs_to :user
  belongs_to :vacation_status  
  
  after_create :change_vacation
  
  validates_presence_of :user_id, :start_date, :vacation_status_id
  validate :dates_is_range
  
  def to_s
    str = format_date(start_date)
    str + ' - ' + format_date(end_date) if end_date.present?
  end
  
  def dates_is_range
    if self.end_date.present? and self.start_date > self.end_date
      errors.add :end_date, :invalid
    end
  end
  
  def change_vacation
    vacation = Vacation.find_by_user_id(user_id) || Vacation.create(:user_id => user_id)

    if vacation_status.is_planned?
      if vacation.active_planned_vacation &&
        vacation.active_planned_vacation.start_date < start_date
        vacation.update_attribute(:last_planned_vacation_id,
          vacation.active_planned_vacation_id)
        vacation.update_attribute(:active_planned_vacation_id,
          self.id)
      elsif vacation.last_planned_vacation &&
        vacation.last_planned_vacation.start_date < start_date
        vacation.update_attribute(:last_planned_vacation_id,
          self.id)
      else
        vacation.update_attribute(:active_planned_vacation_id,
          self.id)
      end
    else
      vacation.update_attribute(:not_planned_vacation_id, self.id)
    end
  end
end
