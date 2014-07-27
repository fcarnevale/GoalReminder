require 'active_record'

class Task < ActiveRecord::Base
  belongs_to :user

  def self.add_task(user, content)
    user.tasks.create(content: content)
  end
end