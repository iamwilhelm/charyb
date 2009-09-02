require 'rubygems'
require 'sinatra'
require 'active_record'

require 'erb'

get '/' do
  erb :index
end

