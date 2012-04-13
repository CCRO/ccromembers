class AddAsinToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :asin, :string

  end
end
