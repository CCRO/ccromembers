class AddCrocodocUuidsToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :crocodoc_uuids, :text

  end
end
