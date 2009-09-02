require 'rubygems'
require 'sinatra'
require 'active_record'

require 'erb'
require 'source'

get '/' do
  erb :index
end

get '/sources' do
  @sources = Charyb::Source.find(:all)
  erb :"sources/index"
end
