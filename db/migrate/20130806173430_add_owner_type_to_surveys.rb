class AddOwnerTypeToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :owner_type, :string
  end
end
