class Billboard < ActiveRecord::Base
  attr_accessible :active, :archived, :body, :title
end
