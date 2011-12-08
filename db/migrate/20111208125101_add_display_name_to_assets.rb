class AddDisplayNameToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :display_name, :string
  end
end
