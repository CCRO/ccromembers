class AddOtherLevelsToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :comment_level, :string, :default => "committee"

    add_column :attachments, :download_level, :string, :default => "committee"

  end
end
