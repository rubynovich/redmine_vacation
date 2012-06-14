class CreateVacationManagers < ActiveRecord::Migration
  def self.up
    create_table :vacation_managers do |t|
      t.column :user_id, :integer
    end
  end

  def self.down
    drop_table :vacation_managers
  end
end
