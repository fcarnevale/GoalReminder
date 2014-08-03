require 'active_record'

class User < ActiveRecord::Base
  has_many :goals
  has_many :activities
  has_many :moods

  MOBILE_PHONE_REGEX = /\A\+\d{11}\z/
  validates_format_of :mobile_phone, with: MOBILE_PHONE_REGEX, on: :create

  def active_goals
    goals.where(active: true)
  end

  def recent_activities_summary
    recent_activities = activities.order(created_at: :desc).limit(3)
    activities_string = recent_activities.empty? ? "You have no recent activities." : "Recent activities:\n"
  
    recent_activities.each_with_index do |activity, index|
      activities_string += "#{index + 1}. #{activity.content}\n"
    end

    activities_string        
  end
end