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
    @active_goals = user.active_goals

    if @active_goals.any?
      today = Date.today
      message = Goal.active_goals_for(user)

      if today.friday?
        message += "\nRemember to set your goal(s) for next week! "
        message += "The active goals above have been archived." if @active_goals.any?

        @account.messages.create(
          :from => @from, 
          :to => user.mobile_phone,
          :body => message
        )

        Goal.deactivate_goals_for(user)
      else
        message += "\nComplete finished goals before they get archived as incomplete!"
        
        @account.messages.create(
          :from => @from, 
          :to => user.mobile_phone,
          :body => message
        )
      end

      reminder_sms_count += 1
    else
      @account.messages.create(
        :from => @from, 
        :to => user.mobile_phone,
        :body => 'Remember to set your goal(s) for next week!'
      )
    end
  end
rescue Exception => e
  @account.messages.create(
    :from => @from, 
    :to => @google_voice_number,
    :body => "Error running goal reminder script: #{e}"
  )
# ensure
#   @account.messages.create(
#     :from => @from, 
#     :to => @google_voice_number,
#     :body => "Finished running goal reminder script.\n# of reminders sent: #{reminder_sms_count}."
#   )
end
  