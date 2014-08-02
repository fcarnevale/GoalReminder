require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
require './models/user'
require 'twilio-ruby'
require './lib/incoming_sms'
require 'pry'
require 'openssl'
require 'base64'

get '/gitterdone' do
  request_uri = request.env['REQUEST_URI']
  key = ENV['TWILIO_AUTH_TOKEN']
  digest = OpenSSL::Digest.new('sha1')

  hashed_request = OpenSSL::HMAC.digest(digest, key, request_uri)
  encoded_request = Base64.encode64(hashed_request).chomp
  twilio_signature = request.env['HTTP_X_TWILIO_SIGNATURE']
  authorized = encoded_request == twilio_signature

  if authorized
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
