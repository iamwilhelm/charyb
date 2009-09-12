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

######### Global Filters ##########


######### Front page routes ##########

# new datasource.  The front page for entering urls
get '/' do
  redirect "/datasources"
end

########## Datasource routes ##########

# lists data sources in the db
get '/datasources' do
  @datasources = Charyb::SourceTracker.datasources
  erb :"/datasources/index"
end

# shows a created data source
get '/datasources/:id' do
  @datasource = Models::Datasource.find(params["id"], :include => ["cols"])
  @ds_response = open(@datasource.url) { |f| f.read }

  # filter out certain tags
  puts @ds_response.length
  @ds_response.gsub!(/<script.*>.*<\/script>/, "")
  puts @ds_response.length
  @ds_response.gsub!(/<script.*\/>/, "")
  puts @ds_response.length
  @ds_response.gsub!(/<object.*>.*<\/object>/, "")
  puts @ds_response.length
  @ds_response.gsub!(/<embed.*>.*<\/embed>/, "")
  puts @ds_response.length

  case @datasource.content_type
  when "text/html"
    @doc = Hpricot(@ds_response, :fixup_tags => true)
  when "application/xml"
    @doc = Hpricot::XML(@ds_response)
  end

  erb :"/datasources/show"
end

# creates a data source
post '/datasources' do
  # TODO this can be refactored into the source tracker
  @datasource = Models::Datasource.find_by_url(params["source"]["url"])
  if @datasource.nil?
    response = open(params["source"]["url"])
    @datasource = Models::Datasource.create!("url" => params["source"]["url"], 
                                         "content_type" => response.content_type)
  end
  redirect "/datasources/#{@datasource.id}"
end

# editing data source ajax
get '/datasources/:id/edit' do
  @datasource = Models::Datasource.find(params["id"])
  erb :"/datasources/edit", :layout => false
end

# updating data source ajax
put '/datasources/:id' do
  @datasource = Models::Datasource.find(params["id"])
  @datasource.update_attributes!(params["source"])

  redirect back
  # erb :"/datasources/_source", :layout => false
end

########## Column routes ##########

# new column ajax
get '/datasources/:source_id/cols/new' do
  @datasource = Models::Datasource.find(params["source_id"])
  @col = @datasource.cols.new
  erb :"/cols/new", :layout => false 
end

# create column ajax
post '/datasources/:source_id/cols' do
  @datasource = Models::Datasource.find(params["source_id"])
  @col = @datasource.cols.create!(params["col"])

  redirect back
end

# edit column ajax
get '/datasources/:source_id/cols/:id/edit' do
  @datasource = Models::Datasource.find(params["source_id"])
  @col = @datasource.cols.find(params["id"])
  erb :"/cols/edit", :layout => false
end

# update column 
put '/datasources/:source_id/cols/:id' do
  @datasource = Models::Datasource.find(params["source_id"])
  @col = @datasource.cols.find(params["id"])
  @col.update_attributes(params["col"])
  
  redirect back
end
