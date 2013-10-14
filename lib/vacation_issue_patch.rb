require_dependency 'issue'

module VacationPlugin
  module IssuePatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do
        validate :assigned_to_on_vacation_create, :on => :create
        # FIXME
        #validate :assigned_to_on_vacation_update, :on => :update

        attr_accessor :attributes_before_change

        if Rails::VERSION::MAJOR >= 3
          scope :on_vacation, lambda{ |vacation_range|
            { :conditions => ["(start_date BETWEEN :start_date AND :end_date) OR (due_date BETWEEN :start_date AND :end_date)", {
              :start_date => vacation_range.start_date,
              :end_date => vacation_range.end_date}]
            }
          }

          scope :with_author, lambda{ |user_id|
            where(:author_id => user_id)
          }

          scope :with_assigned_to, lambda{ |user_id|
            where(:assigned_to_id => user_id)
          }
        else
          named_scope :on_vacation, lambda{ |vacation_range|
            { :conditions => ["(start_date BETWEEN :start_date AND :end_date) OR (due_date BETWEEN :start_date AND :end_date)", {
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

    end

    module ClassMethods
    end

    module InstanceMethods
      def assigned_to_on_vacation_create
        if vacation = Vacation.find_by_user_id(self.assigned_to_id)
          if on_vacation?(vacation_range = vacation.active_planned_vacation) ||
              on_vacation?(vacation_range = vacation.last_planned_vacation) ||
              on_vacation?(vacation_range = vacation.not_planned_vacation)

            errors.add :assigned_to_id, :on_vacation,
              :from => vacation_range.start_date.strftime("%d.%m.%Y"),
              :to => vacation_range.end_date.strftime("%d.%m.%Y")
          end
        end
      end

      def assigned_to_on_vacation_update
        if @attributes_before_change.present? &&
          (@attributes_before_change['assigned_to_id'] != self.assigned_to_id)
          assigned_to_on_vacation_create
        end
      end

      def on_vacation?(vacation_range)
        vacation_range.present? && self.start_date.present? && self.due_date.present? &&
            vacation_range.in_range?(self.start_date, self.due_date)
      end
    end
  end
end
