class CreatePeopleSmartListsTable < ActiveRecord::Migration
  def self.up
    create_table :people_smart_lists, :id => false do |t|
        t.references :person
        t.references :smart_list
    end
    add_index :people_smart_lists, [:person_id, :smart_list_id]
    add_index :people_smart_lists, [:smart_list_id, :person_id]
  end

  def self.down
    drop_table :people_smart_lists
  end
end
