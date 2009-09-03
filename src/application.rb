require 'config/initialize'

require 'rubygems'
require 'sinatra'

require 'erb'
require 'source_tracker'

# setups up the source tracker database if it hasn't been already
Charyb::SourceTracker.setup

get '/' do
  erb :index
end

get '/sources' do
  @sources = Charyb::SourceTracker.datasources
  erb :"sources/index"
end
