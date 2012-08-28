class AddMobilePhoneToPeople < ActiveRecord::Migration
  def change
    add_column :people, :mobile_phone, :string

  end
end
