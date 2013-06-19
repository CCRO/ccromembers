class AddGroupIdToBillboards < ActiveRecord::Migration
  def change
    add_column :billboards, :group_id, :integer
  end
end
