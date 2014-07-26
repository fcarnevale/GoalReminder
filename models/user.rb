require 'date'

class User < ActiveRecord::Base
  def created_today
    created_at.to_date == Date.today
  end
end