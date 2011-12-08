class AddDisplayNameToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :file_name, :string
  end
end
