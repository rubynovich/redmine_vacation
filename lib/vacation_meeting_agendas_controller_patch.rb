module RedmineVacation
  module Patches
    module MeetingAgendasControllerPatch
      extend ActiveSupport::Concern
      included do
        before_filter :check_approvers, :if => Proc.new{ @object && (! @object.approved?) }
      end

      def check_approvers
        @object.meeting_approvers.each do |item|
          if (! item.approved?) && (! item.deleted)
            item.update_column(:deleted, true) if @object.member_on_vacation?(item.user)
          end
        end
      end

    end
  end
end