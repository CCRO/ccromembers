class AddArchiveToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :archived, :boolean

  end
end
