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

  @client = Twilio::REST::Client.new(@account_sid, @auth_token)
  @account = @client.account 

  Goal.where(active: true).find_each do |goal|
    message = "Goal reminder: #{goal.content}"
    @account.messages.create(
      :from => @from, 
      :to => goal.user_mobile_phone,
      :body => message
    )

    if Date.today.friday?
      goal.active = false
      goal.save

      @account.messages.create(
        :from => @from, 
        :to => goal.user_mobile_phone,
        :body => 'Remember to set your new goal(s) for next week!'
      )
    end
  end
rescue Exception => e
  @account.messages.create(
    :from => @from, 
    :to => @from,
    :body => "Error running goal reminder script: #{e}."
  )
ensure
  @account.messages.create(
    :from => @from, 
    :to => @from,
    :body => "Finished running goal reminder script."
  )
end
  