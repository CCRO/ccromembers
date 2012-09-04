class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :title
      t.text :header
      t.text :body
      t.integer :owner_id
      t.integer :owner_type
      t.integer :author_id
      t.datetime :created_at
      t.datetime :updated_at
      t.boolean :published
      t.datetime :published_at
      t.string :level
      t.string :viewing_token
      t.boolean :locked
      t.integer :locker_id
      t.datetime :locked_at
      t.string :tag_list
      t.boolean :commenting_enabled

      t.timestamps
    end
  end
end
