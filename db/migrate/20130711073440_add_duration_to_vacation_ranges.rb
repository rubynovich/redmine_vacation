class AddDurationToVacationRanges < ActiveRecord::Migration
  def change
    add_column :vacation_ranges, :duration, :integer
  end
end
