class SmartList < ActiveRecord::Base
	has_and_belongs_to_many :people
	acts_as_taggable

	def self.search(search)
	  if search
	    where('name LIKE ?', "%#{search}%")
	  else
	    scoped
	  end
	end
end
