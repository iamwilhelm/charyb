
# add paths
CURRENT_PATH = File.expand_path(File.dirname(__FILE__))
$: << 
  File.join(CURRENT_PATH, "../config") <<
  File.join(CURRENT_PATH, "../lib") <<
  File.join(CURRENT_PATH, "../src")
ROOT_PATH = File.join(CURRENT_PATH, "..")

module Charyb  
  SESSION_PATH = File.join(CURRENT_PATH, "../tmp")

  # The default data warehouse name were we stuff all the formatted data 
  # into our data warehouse
  DEFAULT_DATA_WAREHOUSE_NAME = "teabag"

  # The place where we log what's going on
  LOG_PATH = File.join(ROOT_PATH, "log")

  # The place where the sources database is
  SOURCES_PATH = File.join(ROOT_PATH, "sources")
end
