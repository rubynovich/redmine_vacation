if Rails::VERSION::MAJOR >= 3
  RedmineApp::Application.routes.draw do
    resources :vacation_managers, :only => [:index, :create, :destroy]
    resources :vacation_statuses
    resources :vacation_ranges
    resources :vacations  
  end
else
  ActionController::Routing::Routes.draw do |map|
    map.resources :vacation_managers, :only => [:index, :create, :destroy]
    map.resources :vacation_statuses
    map.resources :vacation_ranges
    map.resources :vacations
  end
end
