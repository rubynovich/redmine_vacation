require 'redmine'
require 'dispatcher'
require 'vacation_user_patch'
require 'vacation_issue_patch'

Dispatcher.to_prepare do
  User.send(:include, VacationUserPatch) unless User.include? VacationUserPatch
  Issue.send(:include, VacationIssuePatch) unless Issue.include? VacationIssuePatch
end

Redmine::Plugin.register :redmine_vacation do
  name 'Redmine Vacation plugin'
  author 'Roman Shipiev'
  description 'Makes it impossible issue assignment the employee is on vacation'
  version '0.1.1'
  url 'http://github.com/rubynovich/redmine_vacation'
  author_url 'http://roman.shipiev.me'

  menu :application_menu, :vacations, 
    {:controller => :vacations, :action => :index}, 
    :caption => :label_vacation_plural, 
    :if => Proc.new{ User.current.is_vacation_manager? }

  menu :application_menu, :vacation_ranges, 
    {:controller => :vacation_ranges, :action => :index}, 
    :caption => :label_vacation_range_plural, 
    :if => Proc.new{ User.current.is_vacation_manager? }

  menu :application_menu, :vacation_statuses, 
    {:controller => :vacation_statuses, :action => :index}, 
    :caption => :label_vacation_status_plural, 
    :if => Proc.new{ User.current.is_vacation_manager? }
  
  menu :admin_menu, :vacation_managers, 
    {:controller => :vacation_managers, :action => :index}, :caption => :label_vacation_manager_plural, :html => {:class => :users}
end
