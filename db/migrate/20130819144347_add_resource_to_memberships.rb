class AddResourceToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :resource, :string
    add_column :memberships, :resource_id, :integer
  end
end
