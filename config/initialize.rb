# This is where we initialize constants and paths

old_verbose, $VERBOSE = $VERBOSE, nil
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
  MIGRATIONS_ROOT = File.join(DATASOURCES_ROOT, "migrations")
  SCHEMA_PATH = File.join(DATASOURCES_ROOT, "schema.rb")

  # The place where the sinatra web app file is
  WEBAPP_ROOT = File.join(ROOT_PATH, "src")
  WEBAPP_PATH = File.join(WEBAPP_ROOT, "application.rb")

  # The place where tests are
  TEST_ROOT = File.join(ROOT_PATH, "test")
  MOCKS_ROOT = File.join(TEST_ROOT, "mocks")
end 
$VERBOSE = old_verbose


# add application's source directories to lib search path
$: << 
  File.join(Charyb::ROOT_PATH, "config") << 
  File.join(Charyb::ROOT_PATH, "lib") << 
  Charyb::WEBAPP_ROOT <<
  File.join(Charyb::WEBAPP_ROOT, "models")

# add the core extensions to the Ruby language
Dir.glob(File.join(Charyb::ROOT_PATH, "lib/core_ext/*.rb")).each do |core_ext_path|
  require core_ext_path
end

# add the required gems
require 'rubygems'

# add active record for database access
require 'active_record'

# parses HTML files for html data source parser
require 'hpricot'

# application wide requires
require 'models'

module Charyb
  # set the datasource logger
  ActiveRecord::Base.logger = Logger.new(DATASOURCES_LOG_PATH)

  # establish the active record connection to datasource db
  @connection = ActiveRecord::Base.establish_connection(:adapter => "sqlite3",
                                                        :dbfile => DATASOURCES_PATH)
end
