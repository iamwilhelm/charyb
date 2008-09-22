
# add paths
CURRENT_PATH = File.expand_path(File.dirname(__FILE__))
$: << 
  File.join(CURRENT_PATH, "../config") <<
  File.join(CURRENT_PATH, "../lib") <<
  File.join(CURRENT_PATH, "../src")

module Thoughtless
  SESSION_PATH = File.join(CURRENT_PATH, "../tmp")

  DATABASE_NAME = "thoughtless"
end
