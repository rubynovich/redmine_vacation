class CreateVacations < ActiveRecord::Migration
  def self.up
    create_table :vacations do |t|
      t.column :user_id, :integer
      t.column :last_planned_vacation_id, :integer
      t.column :active_planned_vacation_id, :integer
      t.column :not_planned_vacation_id, :integer
    end
  end

  def self.down
    drop_table :vacations
  end
end
