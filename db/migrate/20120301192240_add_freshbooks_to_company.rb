class AddFreshbooksToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :freshbooks_id, :string

  end
end
