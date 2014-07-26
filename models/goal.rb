class Goal < ActiveRecord::Base
  belongs_to :user

  def self.add_goal(user, content)
    user.goals.create(content: content, active: true)
  end
end