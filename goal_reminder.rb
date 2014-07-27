require './models/user'
require './models/goal'
require 'twilio-ruby'
require 'date'

begin
  db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/goal_reminder_development')
   
  ActiveRecord::Base.establish_connection(
    :adapter => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
    :host     => db.host,
    :username => db.user,
    :password => db.password,
    :database => db.path[1..-1],
    :encoding => 'utf8'
  )

  @account_sid = ENV['TWILIO_SID']
  @auth_token = ENV['TWILIO_AUTH_TOKEN'] 
  @from = ENV['TWILIO_PHONE_NUMBER']
  @google_voice_number = ENV['GOOGLE_VOICE_NUMBER']

  @client = Twilio::REST::Client.new(@account_sid, @auth_token)
  @account = @client.account 

  reminder_sms_count = 0

  User.find_each do |user|
    active_goals_string = Goal.active_goals_for(user)
    
    unless active_goals_string.blank?
      message = "Daily Goal Reminder\n"
      message += active_goals_string

      @account.messages.create(
        :from => @from, 
        :to => user.mobile_phone,
        :body => message
      )

      reminder_sms_count += 1

      if Date.today.friday?
        Goal.deactivate_goals_for(user)

        @account.messages.create(
          :from => @from, 
          :to => user.mobile_phone,
          :body => 'Remember to set your new goal(s) for next week!'
        )
      end
    end
  end
rescue Exception => e
  @account.messages.create(
    :from => @from, 
    :to => @google_voice_number,
    :body => "Error running goal reminder script: #{e}"
  )
ensure
  @account.messages.create(
    :from => @from, 
    :to => @google_voice_number,
    :body => "Finished running goal reminder script.\n# of reminders sent: #{reminder_sms_count}."
  )
end
  