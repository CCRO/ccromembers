class AddCrocodocToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :viewer_uuid, :string

    add_column :documents, :viewer_uuid_updated_at, :timestamp

  end
end
