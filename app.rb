require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
require './models/user'
require 'twilio-ruby'
require './lib/incoming_sms'
require 'pry'

get '/gitterdone' do
  if params
    twiml = Twilio::TwiML::Response.new do |r|
      phone_number = params[:From]
      message = params[:Body]
      user = IncomingSMS.find_or_create_user(phone_number) unless phone_number.blank?

      r.Message IncomingSMS.handle_message(user, message) if message
    end
    twiml.text
  else
    "Gitterdone!"
  end
end