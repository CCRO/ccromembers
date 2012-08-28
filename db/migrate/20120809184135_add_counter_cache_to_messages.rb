class AddCounterCacheToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :counter_cache, :integer

  end
end
