require 'active_record'

class User < ActiveRecord::Base
  has_many :goals
  has_many :tasks

  MOBILE_PHONE_REGEX = /\A\+\d{11}\z/
  validates_format_of :mobile_phone, with: MOBILE_PHONE_REGEX, on: :create

  def active_goals
    goals.where(active: true)
  end

  def recent_tasks_summary
    recent_tasks = tasks.order(created_at: :desc).limit(3)
    tasks_string = recent_tasks.any? ? "Recent tasks:\n" : "You have no recent tasks"
  
    recent_tasks.each do |task|
      tasks_string += "#{task.content}, "
    end
    tasks_string += "."

    tasks_string        
  end
end