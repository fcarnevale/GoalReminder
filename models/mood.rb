require 'active_record'

class Mood < ActiveRecord::Base
  belongs_to :user

  def self.track(user, level, content)
    user.moods.create(level: level, content: content)
  end
end