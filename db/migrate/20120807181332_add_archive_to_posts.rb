class AddArchiveToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :archived, :boolean

  end
end
