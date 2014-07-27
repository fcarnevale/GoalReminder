require File.expand_path('../../models/user', __FILE__)
require File.expand_path('../../models/goal', __FILE__)

class IncomingSMS
  ALLOWABLE_USER_METHODS = [:goal, :goals, :completed]

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
      content.strip!

      if ALLOWABLE_USER_METHODS.include?(user_command)
        self.send(user_command, user, content)
      else
        "Text your goals for the week, one by one, like so 'Goal yourgoalhere'. Valid commands: goal, goals, & completed."
      end
    end

    def goal(user, content)
      return 'Please enter a goal!' if content.blank?

      Goal.add_goal(user, content)

      "#{content[0..50]}... added as a goal!"
    end

    def goals(user, content)
      #fixme: figure out how to avoid having to pass content in this case
      Goal.active_goals_for(user)
    end

    def completed(user, content)
      active_goals = user.active_goals

      if active_goals.empty?
        "You have no active goals to complete."
      else
        active_goals_string = Goal.active_goals_for(user)

        if content.blank?
          instructions_string = "Reply with 'Completed goal# goal# etc...'\n"
          instructions_string += active_goals_string
          
          instructions_string
        else
          goal_ids = content.split(' ')
          summary_string = "Completed summary: "

          goal_ids.each do |id|
            index = id.to_i - 1

            #fixme: super ugly - letters converted to int = 0 though
            if active_goals[index] && index >= 0
              active_goals[index].complete!
              summary_string += "Goal #{id} marked complete! "
            else
              summary_string += "Goal #{id} is invalid. "
            end
          end

          summary_string
        end
      end
    end
  end
end