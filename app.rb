require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
require './models/user'
require 'twilio-ruby'
 
get '/' do
    "Hello, World!"
end

get '/gitterdone' do
  twiml = Twilio::TwiML::Response.new do |r|
    r.Message "Hallo! Testing this bad boy out!"
  end
  twiml.text
end