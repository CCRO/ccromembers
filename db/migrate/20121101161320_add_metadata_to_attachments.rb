class AddMetadataToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :title, :string

    add_column :attachments, :description, :text

    add_column :attachments, :content_type, :string

    add_column :attachments, :file_size, :string

    add_column :attachments, :archived, :boolean

  end
end
