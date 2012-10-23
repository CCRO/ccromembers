class AddConfPhoneToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :conf_phone, :string

  end
end
