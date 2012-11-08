class AddHighriseCacheToPeople < ActiveRecord::Migration
  def change
    add_column :people, :highrise_cache, :text

    add_column :people, :highrise_cached_at, :timestamp

  end
end
