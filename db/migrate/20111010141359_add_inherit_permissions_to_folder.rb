class AddInheritPermissionsToFolder < ActiveRecord::Migration
  def self.up
    add_column :folders, :inherit_permissions, :boolean, :default => true
  end

  def self.down
    remove_column :folders, :inherit_permissions
  end
end
