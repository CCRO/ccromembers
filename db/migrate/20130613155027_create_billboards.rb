class CreateBillboards < ActiveRecord::Migration
  def change
    create_table :billboards do |t|
      t.string :title
      t.text :body
      t.boolean :active
      t.boolean :archived

      t.timestamps
    end
  end
end
