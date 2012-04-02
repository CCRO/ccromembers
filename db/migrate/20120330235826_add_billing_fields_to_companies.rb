class AddBillingFieldsToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :billing_status, :string

    add_column :companies, :expires_on, :date

    add_column :companies, :active, :boolean

    add_column :companies, :balance, :float

  end
end
