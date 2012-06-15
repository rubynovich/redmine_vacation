ActionController::Routing::Routes.draw do |map|
  map.resources :vacation_managers, :only => [:index, :create, :destroy]
  map.resources :vacation_statuses
end
