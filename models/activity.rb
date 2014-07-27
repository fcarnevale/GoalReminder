require 'active_record'

class Activity < ActiveRecord::Base
  belongs_to :user

  def self.add_activity(user, content)
    user.activities.create(content: content)
  end
end