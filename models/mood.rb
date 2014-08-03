require 'active_record'
require 'date'

class Mood < ActiveRecord::Base
  belongs_to :user

  def self.track(user, level, content)
    user.moods.create(level: level, content: content)
  end

  def self.average_for(user, num_days)
    # if num_days comes in blank, i.e. user just entered
    # 'moods' and no num_days, give default of 7 days
    num_days = num_days.to_i > 0 ? num_days.to_i : 7

    today = Date.today
    start_day = today - num_days

    moods = Mood.where('created_at > ?', start_day.to_time).pluck(:level)
    
    unless moods.empty?
      average_mood = moods.inject(0.0) { |sum, n| sum += n } / moods.size
      average_mood = average_mood.round(1)

      return average_mood
    end

    return "Not enough mood data to compute an avg."
  end
end