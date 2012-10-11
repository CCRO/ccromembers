class ChangeGroupTypeTypeOnPages < ActiveRecord::Migration
  def self.up
    change_table :pages do |t|
      t.change :owner_type, :string
    end
  end

  def self.down
    change_table :pages do |t|
      t.change :owner_type, :integer
    end
  end
end
