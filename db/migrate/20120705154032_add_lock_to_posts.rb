class AddLockToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :locked, :boolean

    add_column :posts, :locker_id, :integer

    add_column :posts, :locked_at, :timestamp

  end
end
