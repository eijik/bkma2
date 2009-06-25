class Urllist < ActiveRecord::Base
  has_many :comment , :dependent => :delete_all
  has_many :bkmafolder , :dependent => :delete_all      
end