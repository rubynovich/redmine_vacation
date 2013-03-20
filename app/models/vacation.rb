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

  if Rails::VERSION::MAJOR >= 3
    scope :like_name, lambda {|q|
      if q.present?
        {:conditions =>
          ["LOWER(users.firstname) LIKE :p OR users.firstname LIKE :p OR LOWER(users.lastname) LIKE :p OR users.lastname LIKE :p",
          {:p => "%#{q.to_s.downcase}%"}],
         :joins => :user}
      end
    }
  else
    named_scope :like_name, lambda {|q|
        if q.present?
          {:conditions =>
            ["LOWER(users.firstname) LIKE :p OR users.firstname LIKE :p OR LOWER(users.lastname) LIKE :p OR users.lastname LIKE :p",
            {:p => "%#{q.to_s.downcase}%"}],
           :joins => :user}
        end
      }
  end
end
