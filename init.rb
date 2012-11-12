require 'redmine'

if Rails::VERSION::MAJOR < 3
  require 'dispatcher'
  object_to_prepare = Dispatcher
else
  object_to_prepare = Rails.configuration
end

object_to_prepare.to_prepare do
  [:user, :issue, :issues_controller].each do |cl|
    require "vacation_#{cl}_patch"
  end

  [ 
    [User, VacationPlugin::UserPatch],
    [Issue, VacationPlugin::IssuePatch],
    [IssuesController, VacationPlugin::IssuesControllerPatch],    
  ].each do |cl, patch|
    cl.send(:include, patch) unless cl.included_modules.include? patch
  end
end

Redmine::Plugin.register :redmine_vacation do
  name 'Отсутствия'
  author 'Roman Shipiev'
  description 'Фиксирует отсуствия работников на рабочем месте и не позволяет назначить задачу отсутствующему сотруднику. Если задача поставляена, а сотрудник заявил об отсутствии, то рассылаются соответствующие уведомнения авторам и исполнителям этой задачи.'
  version '0.1.4'
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
