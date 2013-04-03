class AddStretchToPages < ActiveRecord::Migration
  def change
    add_column :pages, :stretch, :boolean, :default => false

  end
end
