class CreateObservers < ActiveRecord::Migration
  def change
    create_table :observers do |t|
      t.references :person
      t.references :message
      t.timestamps
    end
  end
end
