class AddLocationToBillboards < ActiveRecord::Migration
  def change
    add_column :billboards, :location, :string
  end
end
