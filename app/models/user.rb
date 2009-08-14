class User  < ActiveRecord::Base
     has_many :bkmafolder
     has_many :urllist , :through =>:bkmafolder
end