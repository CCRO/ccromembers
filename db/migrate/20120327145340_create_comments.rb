class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :subject
      t.string :content
      t.integer :author_id
      t.integer :commentable_id
      t.string :commentable_type
      t.integer :version_id
      t.text :quote

      t.timestamps
    end
  end
end
