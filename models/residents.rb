class Residents < ActiveRecord::Base
    attr_accessible :name, :addr, :email, :pnum
end
