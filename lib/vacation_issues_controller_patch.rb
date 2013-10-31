require_dependency 'issues_controller'

module VacationPlugin
  module IssuesControllerPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do
        before_filter :warning_flash, only: [:create, :update]
        before_filter :set_attributes_before_change, only: [:update]
      end

    end

    module ClassMethods
    end

    module InstanceMethods
      def set_attributes_before_change
        @issue.attributes_before_change = @attributes_before_change
      end

      def warning_flash
        assigned_to_id = params[:issue][:assigned_to_id]
        due_date = Date.parse(params[:issue][:due_date])
        if (vacation = Vacation.find_by_user_id(assigned_to_id))&&
          (vacation_range = vacation.active_planned_vacation)&&
          (vacation_range.start_date < due_date + 1.month)

          flash[:warning] = t(:vacation_warning_flash,
            :name => User.find(assigned_to_id).name,
            :from => vacation_range.start_date.strftime("%d.%m.%Y"),
            :to => vacation_range.end_date.strftime("%d.%m.%Y"))
        end
      end
    end
  end
end
