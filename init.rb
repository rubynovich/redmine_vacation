require 'redmine'

Redmine::Plugin.register :redmine_vacation do
  name 'Vacation'
  author 'Roman Shipiev'
  description 'Making it impossible issue assignment the employee is on vacation'
  version '0.1.4'
  url 'https://bitbucket.org/rubynovich/redmine_vacation'
  author_url 'http://roman.shipiev.me'

#  menu :application_menu, :vacations,
#    {:controller => :vacations, :action => :index},
#    :caption => :label_vacation_plural,
#    :if => Proc.new{ User.current.is_vacation_manager? }

  menu :application_menu, :vacation_ranges,
    {:controller => :vacation_ranges, :action => :index},
    :caption => :label_vacation_range_plural,
    :if => Proc.new{ User.current.is_vacation_manager? }

#  menu :application_menu, :vacation_statuses,
#    {:controller => :vacation_statuses, :action => :index},
#    :caption => :label_vacation_status_plural,
#    :if => Proc.new{ User.current.is_vacation_manager? }

  menu :admin_menu, :vacation_managers,
    {:controller => :vacation_managers, :action => :index}, :caption => :label_vacation_manager_plural, :html => {:class => :users}
end

Rails.configuration.to_prepare do
  [:user, :issue, :issues_controller].each do |cl|
    require "vacation_#{cl}_patch"
  end

  require_dependency 'vacation_range'
  require 'time_period_scope'

  [
   [User, VacationPlugin::UserPatch],
   [Issue, VacationPlugin::IssuePatch],
   [IssuesController, VacationPlugin::IssuesControllerPatch],
   [VacationRange, TimePeriodScope]
  ].each do |cl, patch|
    cl.send(:include, patch) unless cl.included_modules.include? patch
  end
end
