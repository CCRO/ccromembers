class AddPositionColumnToPages < ActiveRecord::Migration
  def change
    add_column :pages, :position, :string

  end
end
