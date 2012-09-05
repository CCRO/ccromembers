class AddHeaderPictureToPages < ActiveRecord::Migration
  def change
    add_column :pages, :header_picture, :string

  end
end
