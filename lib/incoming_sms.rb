require File.expand_path('../../models/user', __FILE__)
require File.expand_path('../../models/goal', __FILE__)
require File.expand_path('../../models/activity', __FILE__)
require File.expand_path('../../models/mood', __FILE__)

class IncomingSMS
  ALLOWABLE_USER_METHODS = [
    :goal, 
    :goals, 
    :completed, 
    :completedgoals, 
    :i,
    :moods
  ]

  ALLOWABLE_USER_MOODS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

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
      elsif ALLOWABLE_USER_MOODS.include?(user_command.to_s.to_i)
        self.track_mood(user, user_command.to_s.to_i, content)
      else
        "Text your goals for the week, one by one, like so 'Goal yourgoalhere'. Valid commands: goal, goals, & completed."
      end
    end

    def track_mood(user, level, content)
      begin
        Mood.track(user, level, content)
      rescue Exception => e
        puts "///////////////////// Error saving mood entry (#{e}) /////////////////////"
        return "Error saving mood entry."
      end

      "#{level} #{content[0..50]}... added as a mood entry!"
    end

    def moods(user, num_days)
      user.recent_moods_summary(num_days)
    end

    def i(user, content)
      return user.recent_activities_summary if content.blank?
      
      #fixme: duplication with goal method - use yield/blocks for error handling
      begin
        Activity.add_activity(user, content)
      rescue Exception => e
        puts "///////////////////// Error saving activity (#{e}) /////////////////////"
        return "Error saving activity."
      end

      "#{content[0..50]}... added as an activity!"
    end

    def goal(user, content)
      return 'Please enter a goal!' if content.blank?
      
      begin
        Goal.add_goal(user, content)
      rescue Exception => e
        puts "///////////////////// Error saving goal (#{e}) /////////////////////"
        return "Error saving goal."
      end

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

    def completedgoals(user, content)
      #fixme: for now, simply return 3 most recently completed goals

      Goal.recently_completed_by(user) 
    end
  end
end