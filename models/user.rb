require 'date'

class User < ActiveRecord::Base
  has_many :goals

  def created_today
    created_at.to_date == Date.today
  end
end