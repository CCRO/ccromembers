class Moderator < ActiveRecord::Base
	belongs_to :person
	belongs_to :message
end
