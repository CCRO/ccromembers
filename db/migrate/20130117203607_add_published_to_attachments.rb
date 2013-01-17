class AddPublishedToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :published, :string

  end
end
