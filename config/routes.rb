RedmineApp::Application.routes.draw do
  resources :vacation_statuses
  resources :vacation_ranges
  resources :vacations
  resources :vacation_managers, :only => [:index, :create, :destroy] do
    collection do
      get :autocomplete_for_user
    end
  end
end
