class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :subject
      t.string :content
      t.integer :author_id
      t.datetime :published_at

      t.timestamps
    end
  end
end
