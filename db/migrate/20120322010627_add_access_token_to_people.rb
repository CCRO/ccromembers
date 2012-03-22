class AddAccessTokenToPeople < ActiveRecord::Migration
  def change
    add_column :people, :access_token, :string
  end
end
