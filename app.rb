require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
require './models/user'
 
get '/' do
    "Hello, World!"
end