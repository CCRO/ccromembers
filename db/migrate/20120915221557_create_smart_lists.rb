class CreateSmartLists < ActiveRecord::Migration
  def change
    create_table :smart_lists do |t|
      t.string :name
      t.string :type
      t.text :description

      t.timestamps
    end
  end
end
