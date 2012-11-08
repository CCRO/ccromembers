class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.references :group
      t.references :person
      t.string :fuction

      t.timestamps
    end
  end
end
