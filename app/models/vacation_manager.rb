class VacationManager < ActiveRecord::Base
  unloadable
  
  belongs_to :user  
end
