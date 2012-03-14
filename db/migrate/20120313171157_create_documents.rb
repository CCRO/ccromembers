class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :title
      t.text :body
      t.datetime :published_at
      t.references :owner, :polymorphic => true
      t.timestamps
    end
  end
end
