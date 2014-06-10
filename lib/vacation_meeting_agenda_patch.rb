module RedmineVacation
  module Patches
    module MeetingAgendaPatch
      extend ActiveSupport::Concern
      included do
        validate :meeting_members_on_vacation_create
      end

      def meeting_members_on_vacation_create
        members = [self.asserter, self.meeting_questions.map(&:user) , self.meeting_members.map(&:user), self.meeting_approvers.map(&:user)].flatten.uniq.compact
        members.each do |user|
          if vacation = Vacation.find_by_user_id(user.id)
            if on_vacation?(vacation_range = vacation.active_planned_vacation) ||
                on_vacation?(vacation_range = vacation.last_planned_vacation) ||
                on_vacation?(vacation_range = vacation.not_planned_vacation)

              if user == self.asserter
                role = :asserter
              elsif self.meeting_questions.map(&:user).include?(user)
                role = [:meeting_questions, :user]
              elsif self.meeting_approvers.map(&:user).include?(user)
                role = :meeting_approvers
              end
              errors.add role, :on_vacation,
                         :from => vacation_range.start_date.strftime("%d.%m.%Y"),
                         :to => vacation_range.end_date.strftime("%d.%m.%Y"),
                         :user => user
            end
          end
        end

      end



      def member_on_vacation?(user)
        if vacation = Vacation.find_by_user_id(user.id)
          if on_vacation?(vacation_range = vacation.active_planned_vacation) ||
              on_vacation?(vacation_range = vacation.last_planned_vacation) ||
              on_vacation?(vacation_range = vacation.not_planned_vacation)
            return true
          end
        end
        return false
      end

      #def assigned_to_on_vacation_update
      #  if @attributes_before_change.present? &&
      #      (@attributes_before_change['assigned_to_id'] != self.assigned_to_id)
      #    assigned_to_on_vacation_create
      #  end
      #end

      def on_vacation?(vacation_range)
        vacation_range.present? && self.meet_on.present?
          (vacation_range.nil? ? false : vacation_range.include?(self.meet_on))
      end
    end
  end
end