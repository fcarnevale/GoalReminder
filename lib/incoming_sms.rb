require File.expand_path('../../models/user', __FILE__)
require File.expand_path('../../models/goal', __FILE__)

class IncomingSMS
  ALLOWABLE_USER_METHODS = [:goal]

  class << self  
    def find_or_create_user(phone_number)
      user = User.find_or_create_by(mobile_phone: phone_number)
      user
    end

    def handle_message(user, message)
      message = message.to_s # probably unnecessary to convert to string, but I'm being paranoid
    
      user_command = message.split.shift.downcase.to_sym
      content = message.split
      content.shift
      content = content.join(' ')

      if ALLOWABLE_USER_METHODS.include?(user_command)
        self.send(user_command, user, content)
      else
        "Text your goals for the week, one by one, like so 'Goal yourgoalhere'"
      end
    end

    def goal(user, content)
      return 'Please enter a goal!' if content.blank?

      Goal.add_goal(user, content)
      "#{content[0..15]}... added as a goal!"
    end
  end
end