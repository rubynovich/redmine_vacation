class AddDescriptionToVacationRange < ActiveRecord::Migration
  def self.up
    add_column :vacation_ranges, :description, :text
  end

  def self.down
    remove_column :vacation_ranges, :description
  end
end
