class Poll < ActiveRecord::Base
  is_impressionable
  belongs_to :polling_session
end
