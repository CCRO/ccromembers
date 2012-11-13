class AddOptionsToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :options, :text

  end
end
