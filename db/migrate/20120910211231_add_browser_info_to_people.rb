class AddBrowserInfoToPeople < ActiveRecord::Migration
  def change
    add_column :people, :browser_info, :text
  end
end
