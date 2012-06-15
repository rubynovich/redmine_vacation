class CreateVacationStatuses < ActiveRecord::Migration
  def self.up
    create_table :vacation_statuses do |t|
      t.column :name, :string
      t.column :is_default, :boolean
      t.column :is_planned, :boolean
    end
  end

  def self.down
    drop_table :vacation_statuses
  end
end
