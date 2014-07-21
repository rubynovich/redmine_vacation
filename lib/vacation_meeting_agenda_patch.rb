module RedmineVacation
  module Patches
    module MeetingAgendaPatch
      extend ActiveSupport::Concern
      included do
        validate :meeting_members_on_vacation_create
        has_many :meeting_question_users, through: :meeting_questions, class_name: User, source: 'user'
        has_many :meeting_approver_users, through: :meeting_approvers, class_name: User, source: 'user'
      end

      def meeting_members_on_vacation_create
        members = [self.asserter, self.meeting_questions.map(&:user) , self.meeting_members.map(&:user), self.meeting_approvers.where(deleted: false).map(&:user)].flatten.uniq.compact
        members.each do |user|
          if vacation = Vacation.find_by_user_id(user.id)
            if on_vacation?(vacation_range = vacation.active_planned_vacation) ||
                on_vacation?(vacation_range = vacation.last_planned_vacation) ||
                on_vacation?(vacation_range = vacation.not_planned_vacation)

              if user == self.asserter
                role = :asserter
              elsif self.meeting_questions.map(&:user).include?(user)
                role = :meeting_question_users
              elsif self.meeting_approvers.where(deleted: false).map(&:user).include?(user)
                role = :meeting_approver_users
              else
                role = :meeting_members
              end
              errors.add role, :on_vacation,
                         :from => vacation_range.start_date.strftime("%d.%m.%Y"),
                         :to => vacation_range.end_date.strftime("%d.%m.%Y"),
                         :user => user
            end
          end
        end

      end


      def filter_users_on_vacation(users)
        vacation_range_ids = VacationRange.where(["start_date <= ? and end_date >= ?",self.meet_on, self.meet_on]).map(&:id)
        active_planned_vacation_user_ids = Vacation.where(["(active_planned_vacation_id is not null) and (active_planned_vacation_id in (?))", vacation_range_ids]).map(&:user_id)
        last_planned_vacation_user_ids = Vacation.where(["(last_planned_vacation_id is not null) and (last_planned_vacation_id in (?))", vacation_range_ids]).map(&:user_id)
        not_planned_vacation_user_ids = Vacation.where(["(not_planned_vacation_id is not null) and (not_planned_vacation_id in (?))", vacation_range_ids]).map(&:user_id)
        User.where(:id => users.map(&:id)).where(["id not in (?)", [active_planned_vacation_user_ids, last_planned_vacation_user_ids, not_planned_vacation_user_ids].flatten.uniq.compact])
      end



      def member_on_vacation?(user)
        if vacation = Vacation.find_by_user_id(user.id)
          if on_vacation?(vacation_range = vacation.active_planned_vacation) ||
              on_vacation?(vacation_range = vacation.last_planned_vacation) ||
              on_vacation?(vacation_range = vacation.not_planned_vacation)
            return vacation_range
          end
        end
        return nil
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