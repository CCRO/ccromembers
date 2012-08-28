class CreateModerators < ActiveRecord::Migration
  def change
    create_table :moderators do |t|
      t.references :person
      t.references :message
      t.timestamps
    end
  end
end
