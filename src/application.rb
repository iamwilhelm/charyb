require 'config/initialize'

require 'rubygems'
require 'sinatra'

require 'open-uri'
require 'erb'
require 'source_tracker'

configure do
  # sets up the static files path
  set :public, File.join(Charyb::ROOT_PATH, "public")

  # sets up the content types
  mime :json, "application/json"
end

######### Global Filters ##########

######### Helpers ##########
helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

######### Front page routes ##########

# The front page for entering urls
get '/' do
  redirect "/datasources"
end

########## Datasource routes ##########

# Can make new datasource and lists data sources in the db
get '/datasources' do
  @datasources = Charyb::SourceTracker.datasources
  erb :"/datasources/index"
end

# shows a data source
get '/datasources/:id' do
  @datasource = Source::Datasource.find(params["id"], :include => ["cols"])
  @doc = @datasource.document

  erb :"/datasources/show"
end

# creates a data source
post '/datasources' do
  # TODO this can be refactored into the source tracker
  @datasource = Source::Datasource.find_by_url(params["source"]["url"])
  if @datasource.nil?
    response = open(params["source"]["url"])
    @datasource = returning(Source::Datasource.new) do |ds|
      ds.url = params["source"]["url"]
      ds.type = Source::Datasource.class_name_of(response.content_type)
      ds.content_type = response.content_type
    end
    @datasource.save!
  end

  redirect "/datasources/#{@datasource.id}/#{@datasource.url_type}"
end

# editing data source ajax
get '/datasources/:id/edit' do
  @datasource = Source::Datasource.find(params["id"])
  erb :"/datasources/edit", :layout => false
end

# updating data source ajax
put '/datasources/:id' do
  @datasource = Source::Datasource.find(params["id"])
  @datasource.update_attributes!(params["source"])

  redirect "/datasources/#{@datasource.id}/#{@datasource.url_type}"
  # erb :"/datasources/_source", :layout => false
end

# shows a data source of specific type
#--
# we put it down here below /datasources/:id/edit, so that "edit" doesn't get 
# overshadowed by this route
get '/datasources/:id/:type' do
  @datasource = Source.const_get(Source::Datasource.class_name_of(params["type"])).
    find(params["id"], :include => ["cols"])
  @doc = @datasource.document
  
  erb :"/datasources/show"
end

# deletes a data source
delete '/datasources/:id' do
  @datasource = Source::Datasource.find(params["id"])
  @datasource.destroy

  redirect back
end

########## Column routes ##########

# new column ajax
get '/datasources/:source_id/cols/new' do
  @datasource = Source::Datasource.find(params["source_id"])
  @col = @datasource.cols.new
  erb :"/cols/new", :layout => false 
end

# create column ajax
post '/datasources/:source_id/cols' do
  @datasource = Source::Datasource.find(params["source_id"])
  @col = @datasource.cols.create!(params["col"])

  redirect back
end

# edit column ajax
get '/datasources/:source_id/cols/:id/edit' do
  @datasource = Source::Datasource.find(params["source_id"])
  @col = @datasource.cols.find(params["id"])
  erb :"/cols/edit", :layout => false
end

# update column 
put '/datasources/:source_id/cols/:id' do
  @datasource = Source::Datasource.find(params["source_id"])
  @col = @datasource.cols.find(params["id"])
  @col.update_attributes(params["col"])
  
  redirect back
end
