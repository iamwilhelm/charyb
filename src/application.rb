require 'config/initialize'

require 'rubygems'
require 'sinatra'
require 'hpricot'

require 'open-uri'
require 'erb'
require 'source_tracker'

configure do
  # setups up the source tracker database if it hasn't been already
  Charyb::SourceTracker.setup

  # sets up the static files path
  set :public, File.join(Charyb::ROOT_PATH, "public")

  # sets up the content types
  mime :json, "application/json"
end

# The front page for entering urls
get '/' do
  erb :index
end

# lists data sources in the db
get '/sources' do
  @sources = Charyb::SourceTracker.datasources
  erb :"sources/index"
end

# creates a data source
post '/sources' do
  # TODO this can be refactored into the source tracker
  @source = Models::Datasource.find_by_url(params["source"]["url"])
  if @source.nil?
    response = open(params["source"]["url"])
    @source = Models::Datasource.create!("url" => params["source"]["url"], 
                                         "content_type" => response.content_type)
  end
  redirect "sources/#{@source.id}"
end

# shows a created data source
get '/sources/:id' do
  @source = Models::Datasource.find(params["id"], :include => ["cols"])
  @ds_response = open(@source.url) { |f| f.read }

  case @source.content_type
  when "text/html"
    @doc = Hpricot(@ds_response)
  when "application/xml"
    @doc = Hpricot::XML(@ds_response)
  end

  erb :"sources/show"
end

# new column ajax
get '/sources/:source_id/cols/new' do
  @source = Models::Datasource.find(params["source_id"])
  @col = @source.cols.new
  erb :"cols/new", :layout => false 
end

# gets
get '/sources/:source_id/cols/:id' do
end
