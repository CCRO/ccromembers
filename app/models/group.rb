class Group < ActiveRecord::Base
  # create_table "groups", :force => true do |t|
  # t.string   "name"
  # t.datetime "created_at", :null => false
  # t.datetime "updated_at", :null => false

	is_impressionable

  has_many :pages, :as => :owner
  has_many :posts, :as => :owner
  has_many :messages, :as => :owner
  has_many :documents, :as => :owner
  has_many :attachments, :as => :owner
  has_many :memberships
  has_many :people, :through => :memberships
  has_many :comments, :through => :messages, :as => :commentable

  def leadership
    leaders = []
    self.memberships.where(fuction: "chair").each {|l| leaders << Person.find(l.person_id)}
    self.memberships.where(fuction: "coordinator").each {|l| leaders << Person.find(l.person_id)}
    return leaders
  end

end


