class AddCommentingEnabledToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :commenting_enabled, :boolean

  end
end
