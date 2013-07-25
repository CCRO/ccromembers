class AddLogoToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :logo_pic, :string
  end
end
