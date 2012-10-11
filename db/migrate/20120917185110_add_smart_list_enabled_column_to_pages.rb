class AddSmartListEnabledColumnToPages < ActiveRecord::Migration
  def change
    add_column :pages, :smart_lists_enabled, :boolean, default: true
  end
end
