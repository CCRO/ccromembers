class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.references :author, :polymorphic => true
      t.references :owner
      t.string :title
      t.text :discription
      t.boolean :published
      t.timestamp :published_at

      t.timestamps
    end
  end
end
