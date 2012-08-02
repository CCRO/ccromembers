class AddLevelColumnToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :level, :string

  end
end
