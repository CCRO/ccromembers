class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string :file
      t.string :crocodoc_uuid
      t.references :owner, :polymorphic => true
      t.references :author

      t.timestamps
    end
    add_index :attachments, :owner_id
    add_index :attachments, :author_id
  end
end
