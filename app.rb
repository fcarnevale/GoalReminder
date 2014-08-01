require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
require './models/user'
require 'twilio-ruby'
require './lib/incoming_sms'
require 'pry'
require 'digest/hmac'
require 'base64'

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
  # binding.pry
  # request_uri = request.env['REQUEST_URI'].gsub(/\?.*\z/, '')
  request_uri = request.env['REQUEST_URI']
  hashed_request = Digest::HMAC.hexdigest(request_uri, ENV['TWILIO_AUTH_TOKEN'], Digest::SHA1)
  encoded_request = Base64.encode64(hashed_request).chomp
  twilio_signature = request.env['HTTP_X_TWILIO_SIGNATURE']
  authorized = encoded_request == twilio_signature
  debug_text = "request_uri: #{request_uri}, encoded_request: #{encoded_request}, header: #{twilio_signature}"

  if authorized
    twiml = Twilio::TwiML::Response.new do |r|
      r.Message "Authorized request! #{debug_text}"
    end
  else
    twiml = Twilio::TwiML::Response.new do |r|
      r.Message "Unauthorized request! #{debug_text}"
    end
  end
  
  twiml.text  

  # # First, instantiate a RequestValidator object with your account's AuthToken.
  # validator = Twilio::Util::RequestValidator.new(ENV['TWILIO_AUTH_TOKEN'])

  # # Then gather the data required to validate the request. The following works in
  # # sinatra, and something similar should work in any rack-based environment.

  # # Build the URI for this request, including query string params if any.
  # uri = request.env['REQUEST_URI'].gsub(/\?.*\z/, '')

  # # Collect all parameters passed from Twilio.
  # params = request.env['rack.request.query_hash']
  # # If GET, use rack.request.query_hash instead:
  # # params = env['rack.request.query_hash']

  # # Grab the signature from the HTTP header.
  # signature = request.env['HTTP_X_TWILIO_SIGNATURE']

  # # Finally, call the validator's #validate method.
  # authorized = validator.validate uri, params, signature #=> true if the request is from Twilio
end