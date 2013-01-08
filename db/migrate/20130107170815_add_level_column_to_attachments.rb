class AddLevelColumnToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :level, :string, :default => "committee"

  end
end
