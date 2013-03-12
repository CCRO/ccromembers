class AddBioPicToPerson < ActiveRecord::Migration
  def change
    add_column :people, :bio_pic, :string
  end
end
