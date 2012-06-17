class CreateVacationRanges < ActiveRecord::Migration
  def self.up
    create_table :vacation_ranges do |t|
      t.column :user_id, :integer
      t.column :vacation_status_id, :integer
      t.column :start_date, :date
      t.column :end_date, :date
    end
  end

  def self.down
    drop_table :vacation_ranges
  end
end
