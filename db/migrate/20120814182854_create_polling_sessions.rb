class CreatePollingSessions < ActiveRecord::Migration
  def change
    create_table :polling_sessions do |t|
      t.string :name

      t.timestamps
    end
  end
end
