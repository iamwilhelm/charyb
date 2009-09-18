# initialization constants and paths
require File.dirname(__FILE__) + "/../config/initialize"

# require the web app so we can test it
require Charyb::WEBAPP_PATH

# require testing frameworks
require "test/unit"
require "rack/test"
require "webrat"
require "shoulda"

# require mocks, stubs, and blueprints
require "mocha"
require "test/blueprints"

# sets the environment to use test
set :environment, :test
