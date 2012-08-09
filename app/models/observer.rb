class Observer < ActiveRecord::Base
	belongs_to :person
	belongs_to :message
end
