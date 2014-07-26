require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
require './models/user'
require 'twilio-ruby'
require './lib/incoming_sms'
require 'pry'

get '/gitterdone' do
  twiml = Twilio::TwiML::Response.new do |r|
    phone_number = params[:From]
    message = params[:Body]

    user = IncomingSMS.find_or_create_user(phone_number)

    if user.created_today
      r.Message "Hi! Text a goal for the week like so 'Goal yourgoalhere'"
      r.Message IncomingSMS.handle_message(message) if message
    else
      r.Message IncomingSMS.handle_message(message) if message
    end
  end
  twiml.text
end