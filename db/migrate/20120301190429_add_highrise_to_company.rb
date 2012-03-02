class AddHighriseToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :highrise_id, :string

  end
end
