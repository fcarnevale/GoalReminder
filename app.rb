require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
require './models/user'
require 'twilio-ruby'
require './lib/incoming_sms'
require 'pry'
require 'digest/hmac'

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

get '/testingauth' do
  request_uri = request.env['REQUEST_URI']
  hashed_request = Digest::HMAC.hexdigest(request_uri, ENV['TWILIO_AUTH_TOKEN'], Digest::SHA1)
  encoded_request = Base64.encode64(hashed_request)
  authorized = encoded_request == request.env['HTTP_X_TWILIO_SIGNATURE']
  twilio_sig_present = !request.env['HTTP_X_TWILIO_SIGNATURE'].blank?

  if authorized
    twiml = Twilio::TwiML::Response.new do |r|
      r.Message "Authorized request! #{twilio_sig_present}"
    end
  else
    twiml = Twilio::TwiML::Response.new do |r|
      r.Message "Unauthorized request! #{twilio_sig_present}"
    end
  end
  
  twiml.text  
end