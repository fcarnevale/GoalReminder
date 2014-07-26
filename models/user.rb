require 'active_record'

class User < ActiveRecord::Base
  has_many :goals

  def active_goals
    goals.where(active: true)
  end
end