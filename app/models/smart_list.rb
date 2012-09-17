class SmartList < ActiveRecord::Base
	has_and_belongs_to_many :people
	acts_as_taggable
end
