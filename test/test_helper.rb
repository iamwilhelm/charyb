require File.dirname(__FILE__) + "/../config/initialize"

require Charyb::WEBAPP_PATH
require "test/unit"
require "rack/test"
require "webrat"

require "test/blueprints"

set :environment, :test
