class AddFormatToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :format, :string
  end
end
