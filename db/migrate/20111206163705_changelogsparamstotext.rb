class Changelogsparamstotext < ActiveRecord::Migration
  def up
    change_column :logs, :parameters, :text
  end

  def down
    change_column :logs, :parameters, :string
  end
end
