class AddUserIdToHotlinks < ActiveRecord::Migration
  def change
    add_column :hotlinks, :user_id, :integer
  end
end
