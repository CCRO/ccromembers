class SwapAuthorAndOwnerOnPosts < ActiveRecord::Migration
  def up
    rename_column :posts, :owner_type, :author_type
    rename_column :posts, :owner_id, :author_id_temp
    rename_column :posts, :author_id, :owner_id
    rename_column :posts, :author_id_temp, :author_id
  end

  def down
    rename_column :posts, :author_type, :owner_type
    rename_column :posts, :owner_id, :author_id_temp
    rename_column :posts, :author_id, :owner_id
    rename_column :posts, :author_id_temp, :author_id
  end
end
