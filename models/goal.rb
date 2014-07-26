class Goal < ActiveRecord::Base
  belongs_to :user

  def self.add_goal(user, content)
    user.create_goal(content: content)
  end
end