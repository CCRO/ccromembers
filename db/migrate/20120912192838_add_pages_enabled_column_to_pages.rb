class AddPagesEnabledColumnToPages < ActiveRecord::Migration
  def change
    add_column :pages, :pages_enabled, :boolean, default: true
    add_column :pages, :articles_enabled, :boolean, default: true
    add_column :pages, :discussions_enabled, :boolean, default: true
  end
end
