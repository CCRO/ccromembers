class AddOverviewPageToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :overview_page, :integer

  end
end
