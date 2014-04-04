module RedmineVacation
  module Patches
    module MeetingAgendaPatch
      extend ActiveSupport::Concern
      included do
        validate :meeting_members_on_vacation_create
      end

      def meeting_members_on_vacation_create
        self.meeting_members.each do |meeting_member|
          if vacation = Vacation.find_by_user_id(meeting_member.user_id)
            if on_vacation?(vacation_range = vacation.active_planned_vacation) ||
                on_vacation?(vacation_range = vacation.last_planned_vacation) ||
                on_vacation?(vacation_range = vacation.not_planned_vacation)
              errors.add :meeting_members, :on_vacation,
                         :from => vacation_range.start_date.strftime("%d.%m.%Y"),
                         :to => vacation_range.end_date.strftime("%d.%m.%Y")
            end
          end
        end
      end

      #def assigned_to_on_vacation_update
      #  if @attributes_before_change.present? &&
      #      (@attributes_before_change['assigned_to_id'] != self.assigned_to_id)
      #    assigned_to_on_vacation_create
      #  end
      #end

      def on_vacation?(vacation_range)
        vacation_range.present? && self.meet_on.present?
            vacation_range.include?(self.meet_on)
      end
    end
  end
end