class VacationRange < ActiveRecord::Base
  unloadable

  belongs_to :user
  belongs_to :vacation_status

  after_create :change_vacation
  after_save :change_vacation
  after_save :send_notifications

  validates_presence_of :user_id, :start_date, :vacation_status_id
  validates_uniqueness_of :start_date, :scope => :user_id, :on => :create
  validates_uniqueness_of :end_date, :scope => :user_id, :on => :create, :if => Proc.new{ end_date.present? }
  validates_numericality_of :duration, only_integer: true, allow_nil: true
  validate :dates_in_row, if: -> {self.start_date.present? && self.end_date.present?}
  validate :duration_length, if: -> {self.duration.present? && self.start_date.present? && self.end_date.present?}


  def title_description
    if description.present?
      description.gsub(/\r\n/,"\r")
    end
  end

  scope :limit, lambda {|limit|
    where(:limit => limit)
  }

  scope :order_by_start_date, lambda {|q|
    if q.present?
      where(:order => "start_date #{q}")
    else
      where(:order => "start_date")
    end
  }

  scope :for_user, lambda { |user|
    if user.present?
      where("user_id = :user_id", {:user_id => user})
    end
  }

  scope :like_username, lambda {|q|
    if q.present?
      {:conditions =>
        ["LOWER(users.firstname) LIKE :p OR users.firstname LIKE :p OR LOWER(users.lastname) LIKE :p OR users.lastname LIKE :p",
         {:p => "%#{q.to_s.downcase}%"}],
        :include => :user}
    end
  }

  scope :for_vacation_status, lambda { |status|
    if status.present?
      where("vacation_status_id = :status_id", {:status_id => status})
    end
  }

  scope :planned_vacations, lambda {
    {:conditions =>
      ["vacation_statuses.is_planned = :status",
       {:status => true}],
      :joins => :vacation_status}
  }

  scope :not_planned_vacations, lambda {
    {:conditions =>
      ["vacation_statuses.is_planned = :status",
       {:status => false}],
      :joins => :vacation_status}
  }


  def to_s
    str = format_date(start_date)
    if end_date.present?
      str + ' - ' + format_date(end_date)
    else
      str
    end
  end

  def dates_in_row
    if self.end_date.present? and self.start_date > self.end_date
      errors.add :end_date, :invalid
    end
  end

  def duration_length
     if self.duration > (self.end_date - self.start_date)+1
       errors.add :duration, :invalid
     end
  end

  def include?(date)
    self.start_date.present? && self.end_date.present? && (self.start_date <= date) && (self.end_date >= date)
  end

  def in_range?(start, ending)
    ending ||= start
    self.include?(start) || self.include?(ending)
    #|| (start <= self.start_date && ending >= self.end_date)
  end


  def change_vacation
    vacation = Vacation.find_by_user_id(user_id) || Vacation.create(:user_id => user_id)

    active_planned, last_planned = *VacationRange.
      planned_vacations.
      for_user(user_id).
      limit(2).
      all(:order => "start_date DESC, end_date DESC")

    not_planned = VacationRange.
      not_planned_vacations.
      for_user(user_id).
      first(:order => "start_date DESC, end_date DESC")

    vacation.update_attributes(
                               :last_planned_vacation => last_planned,
                               :active_planned_vacation => active_planned,
                               :not_planned_vacation => not_planned
                               )
  end

  def send_notifications
    issues_author = Issue.with_author(self.user_id).open.
      on_vacation(self).inject({}){ |result,issue|
      if issue.assigned_to.present? && issue.assigned_to.is_a?(User)
        result.update(issue.assigned_to_id => [issue.id]){|k,o,n| o+n }\
      else
        result
      end
    }
    issues_assigned_to = Issue.with_assigned_to(self.user_id).open.
      on_vacation(self).inject({}){ |result,issue|
      if issue.author.present?
        result.update(issue.author_id => [issue.id]){|k,o,n| o+n }
      else
        result
      end
    }

    ActiveRecord::Base.transaction do
      issues_author.each{ |assigned_to, issues|
        VacationMailer.deliver_from_author(assigned_to, issues, self.id, self.user_id)
      }
      issues_assigned_to.each{ |author, issues|
        VacationMailer.deliver_from_assigned_to(author, issues, self.id, self.user_id)
      }
    end
  end
end
