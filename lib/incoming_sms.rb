require File.expand_path('../../models/user', __FILE__)

class IncomingSMS
  ALLOWABLE_USER_METHODS = [:help!, :test]

  class << self  
    def find_or_create_user(phone_number)
      user = User.find_or_create_by(mobile_phone: phone_number)
      user
    end

    def handle_message(message)
      message = message.to_s # probably unnecessary to convert to string, but I'm being paranoid
    
      user_command = message.split.shift.downcase.to_sym
      content = message.split
      content.shift
      content = content.join(' ')

      if ALLOWABLE_USER_METHODS.include?(user_command)
        self.send(user_command, content)
      else
        "'Help!' and 'Goal' are the only valid commands"
      end
    end

    def help!
      "Text your goals for the week, one by one, like so 'Goal yourgoalhere'"
    end

    def test(content)
      "Testing metaprogramming. Your message: #{content}."
    end
  end
end