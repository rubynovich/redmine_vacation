class VacationRange < ActiveRecord::Base
  unloadable
  
  belongs_to :user
  belongs_to :vacation_status  
  
  after_create :change_vacation
  after_save :change_vacation
  
  validates_presence_of :user_id, :start_date, :vacation_status_id
  validate :dates_is_range

  named_scope :limit, lambda {|limit|
      {:limit => limit}
  }
  
  named_scope :order_by_start_date, lambda {|q|
    if q.present?
      {:order => "start_date #{q}"}
    else
      {:order => "start_date"}
    end
  }
  
  
  named_scope :for_user, lambda { |user|
    {:conditions => 
        ["user_id = :user", {:user => user}]}
  }
  
  named_scope :planned_vacations, lambda {
    {:conditions => 
      ["vacation_statuses.is_planned = :status", 
      {:status => true}],
    :joins => :vacation_status}
  }
  
  named_scope :not_planned_vacations, lambda {
    {:conditions => 
      ["vacation_statuses.is_planned = :status", 
      {:status => false}],
    :joins => :vacation_status}
  }
  
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
    
    active_planned, last_planned = *VacationRange.
      planned_vacations.
      for_user(user_id).
      limit(2).
      order_by_start_date("DESC").
      all
    
    not_planned = VacationRange.
      not_planned_vacations.
      for_user(user_id).
      order_by_start_date("DESC").
      first
    
    vacation.update_attributes(
      :last_planned_vacation => last_planned,
      :active_planned_vacation => active_planned,
      :not_planned_vacation => not_planned
    )
  end
end
