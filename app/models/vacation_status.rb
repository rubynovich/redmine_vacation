class VacationStatus < ActiveRecord::Base
  unloadable
  after_save     :update_default
  before_destroy :check_integrity
  
  validates_presence_of :name
  validates_uniqueness_of :name
     
  def update_default
    self.class.update_all("is_default=#{connection.quoted_false}", ['id <> ?', id]) if self.is_default?
  end
  
  def self.default
    find(:first, :conditions =>["is_default=?", true])
  end
  
  def to_s
    name
  end
  
  private
    def deletable?
      true
    end
    
    def check_integrity
      raise "Can't delete vacation_status" unless deletable?
    end    
end
