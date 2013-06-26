class AddArchivedToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :archived, :boolean, default: false
  end
end
