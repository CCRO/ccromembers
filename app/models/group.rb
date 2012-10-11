class Group < ActiveRecord::Base
  # create_table "groups", :force => true do |t|
  # t.string   "name"
  # t.datetime "created_at", :null => false
  # t.datetime "updated_at", :null => false

	is_impressionable

  has_many :pages, :as => :owner
  has_many :memberships
  has_many :people, :through => :memberships

end
