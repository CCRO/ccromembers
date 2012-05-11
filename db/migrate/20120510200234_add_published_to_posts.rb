class AddPublishedToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :published, :boolean

    add_column :posts, :published_at, :timestamp

  end
end
