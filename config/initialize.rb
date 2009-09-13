# This is where we initialize constants and paths
module Charyb  
  ROOT_PATH = File.expand_path(File.join(File.dirname(__FILE__), ".."))

  SESSION_PATH = File.join(ROOT_PATH, "tmp")

  # The default data warehouse name were we stuff all the formatted data 
  # into our data warehouse
  DEFAULT_DATAWAREHOUSE_NAME = "teabag"

  # The place where we log what's going on
  LOG_ROOT = File.join(ROOT_PATH, "log")
  DATASOURCES_LOG_PATH = File.join(LOG_ROOT, "datasources.log")

  # The place where the datasources database is
  DATASOURCES_ROOT = File.join(ROOT_PATH, "db")
  DATASOURCES_PATH = File.join(DATASOURCES_ROOT, "datasources.db")

end

# add application's source directories to lib search path
$: << 
  File.join(Charyb::ROOT_PATH, "config") << 
  File.join(Charyb::ROOT_PATH, "lib") << 
  File.join(Charyb::ROOT_PATH, "src") <<
  File.join(Charyb::ROOT_PATH, "src/models")

# add the core extensions to the Ruby language
Dir.glob(File.join(Charyb::ROOT_PATH, "lib/core_ext/*.rb")).each do |core_ext_path|
  require core_ext_path
end

# add the required gems
require 'rubygems'

# add active_support's misc object methods
# http://api.rubyonrails.org/classes/Object.html
require 'active_support/core_ext/object/misc'

# add active record for database access
require 'active_record'

# parses HTML files for html data source parser
require 'hpricot'

module Charyb
  # set the datasource logger
  ActiveRecord::Base.logger = Logger.new(DATASOURCES_LOG_PATH)

  # establish the active record connection to datasource db
  @connection = ActiveRecord::Base.establish_connection(:adapter => "sqlite3",
                                                        :dbfile => DATASOURCES_PATH)
end
