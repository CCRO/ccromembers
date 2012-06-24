class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.references :person
      t.references :question
      t.integer :selected_response
      t.text :text_response

      t.timestamps
    end
    add_index :responses, :person_id
    add_index :responses, :question_id
  end
end
