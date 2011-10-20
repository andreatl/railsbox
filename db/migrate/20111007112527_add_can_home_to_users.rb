class AddCanHomeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :can_home, :boolean
  end

  def self.down
    remove_column :users, :can_home
  end
end
