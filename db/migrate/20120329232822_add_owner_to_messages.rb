class AddOwnerToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :owner_id, :integer

    add_column :messages, :owner_type, :string

  end
end
