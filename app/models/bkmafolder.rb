class Bkmafolder < ActiveRecord::Base
  belongs_to :urllist
  belongs_to :user
end
