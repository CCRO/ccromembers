class AddPerishableTokenToPeople < ActiveRecord::Migration
  def change
    add_column :people, :perishable_token, :string
    add_column :people, :perishable_token_sent_at, :datetime
  end
end
