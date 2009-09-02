require 'config/initialize'

require 'rubygems'
require 'sinatra'

require 'erb'
require 'models'

get '/' do
  erb :index
end

get '/sources' do
  @sources = Models::Source.find(:all)
  erb :"sources/index"
end
