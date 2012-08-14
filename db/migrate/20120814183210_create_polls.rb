class CreatePolls < ActiveRecord::Migration
  def change
    create_table :polls do |t|
      t.text :question
      t.text :choice_a
      t.text :choice_b
      t.text :choice_c
      t.text :choice_d
      t.boolean :active
      t.references :polling_session

      t.timestamps
    end
    add_index :polls, :polling_session_id
  end
end
