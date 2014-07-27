require 'active_record'

class Goal < ActiveRecord::Base
  belongs_to :user

  def self.add_goal(user, content)
    user.goals.create(content: content, active: true)
  end

  def self.active_goals_for(user)
    goals = user.active_goals
    goal_string = goals.any? ? "Active Goals:\n" : "You have no active goals.\n"

    goals.each_with_index do |goal, index|
      goal_string += "#{index + 1}. #{goal.content.capitalize}\n"
    end

    goal_string
  end

  def self.deactivate_goals_for(user)
    user.active_goals.each do |goal|
      goal.active = false
      goal.save
    end
  end

  def self.recently_completed_by(user)
    goal_string = ''

    recently_completed_goals = Goal.where(
      "user_id = ? AND completed = ?", 
      user.id, true
    ).order(created_at: :desc).limit(3)

    return "You have no recently completed goals." if recently_completed_goals.empty?

    recently_completed_goals.each_with_index do |goal, index|
      goal_string += "#{index + 1}. #{goal.content}\n"
    end

    goal_string
  end

  def complete!
    self.completed = true
    self.active = false
    self.save
  end

  def user_mobile_phone
    user.mobile_phone
  end
end