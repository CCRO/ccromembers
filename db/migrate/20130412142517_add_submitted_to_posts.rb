class AddSubmittedToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :submitted, :boolean, default: false

  end
end
