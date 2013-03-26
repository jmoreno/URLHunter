class Prey < ActiveRecord::Base
  attr_accessible :user
  has_many :tweetlinks
end
