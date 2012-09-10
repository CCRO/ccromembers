class AddBrowserInfoToPeople < ActiveRecord::Migration
  def change
    add_column :people, :last_browser, :string

    add_column :people, :last_platform, :string

  end
end
