class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :owner_id
      t.string :owner_type
      t.string :product
      t.string :payment_method
      t.string :payment_id
      t.boolean :active

      t.timestamps
    end
  end
end
