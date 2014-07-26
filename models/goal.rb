require 'active_record'

class Goal < ActiveRecord::Base
  belongs_to :user
  attr_accessor :active

  def self.add_goal(user, content)
    user.goals.create(content: content, active: true)
  end
end