class AddViewingTokenToPostsAndDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :viewing_token, :string
    add_column :posts, :viewing_token, :string
  end
end
