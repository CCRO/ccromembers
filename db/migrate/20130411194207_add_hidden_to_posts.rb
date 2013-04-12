class AddHiddenToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :hidden, :boolean, default: false

  end
end
