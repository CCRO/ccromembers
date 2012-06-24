class AddVerifiedToPeople < ActiveRecord::Migration
  def change
    add_column :people, :verified, :boolean

  end
end
