class AddAuthorIdToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :author_id, :integer

  end
end
