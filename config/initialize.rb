# add paths
ROOT_PATH = File.expand_path(File.join(File.dirname(__FILE__), ".."))

$: << 
  File.join(ROOT_PATH, "config") << 
  File.join(ROOT_PATH, "lib") << 
  File.join(ROOT_PATH, "src") 

# This is where we initialize constants and paths
module Charyb  
  SESSION_PATH = File.join(ROOT_PATH, "tmp")

  # The default data warehouse name were we stuff all the formatted data 
  # into our data warehouse
  DEFAULT_DATAWAREHOUSE_NAME = "teabag"

  # The place where we log what's going on
  LOG_ROOT = File.join(ROOT_PATH, "log")
  DATASOURCES_LOG_PATH = File.join(LOG_ROOT, "datasources.log")

  # The place where the datasources database is
  DATASOURCES_ROOT = File.join(ROOT_PATH, "datasources")
  DATASOURCES_PATH = File.join(DATASOURCES_ROOT, "datasources.db")

end

# initialize connection to source tracking database
require 'rubygems'
require 'active_record'

module Charyb
  # set the datasource logger
  ActiveRecord::Base.logger = Logger.new(DATASOURCES_LOG_PATH)

  # establish the active record connection to datasource db
  @connection = ActiveRecord::Base.establish_connection(:adapter => "sqlite3",
                                                        :dbfile => DATASOURCES_PATH)
end
