class AddContentToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :content, :text

  end
end
