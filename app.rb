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

    r.Message IncomingSMS.handle_message(message) if message
  end
  twiml.text
end