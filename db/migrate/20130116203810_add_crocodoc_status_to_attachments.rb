class AddCrocodocStatusToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :crocodoc_status, :string

    add_column :attachments, :crocodoc_viewable, :boolean

  end
end
