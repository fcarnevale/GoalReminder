require File.expand_path('../../models/user', __FILE__)

class IncomingSMS
  ALLOWABLE_USER_METHODS = [:help]

  class << self  
    def find_or_create_user(phone_number)
      user = User.find_or_create_by(mobile_number: phone_number)
      user
    end

    def handle_message(message)
      message = message.to_s # probably unnecessary to convert to string, but I'm being paranoid
    
      user_command = message.split.shift.downcase
      content = message.split
      content.shift
      content = content.join(' ')

      if ALLOWABLE_USER_METHODS.include?(user_command)
        self.send(user_command, content)
      else
        "'Help' and 'Goal' are the only valid commands"
      end
    end

    def help
      "Text your goals for the week, one by one, like so 'Goal yourgoalhere'"
    end
  end
end