require File.join(File.dirname(__FILE__), *%w[.. .. .. config initialize])

require Charyb::WEBAPP_PATH
# Force the application name because polyglot breaks the auto-detection logic.
Sinatra::Application.app_file = Charyb::WEBAPP_PATH

require 'spec/expectations'
require 'rack/test'
require 'webrat'

Webrat.configure do |config|
  config.mode = :rack
end

class MyWorld
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers

  Webrat::Methods.delegate_to_session :response_code, :response_body

  def app
    Sinatra::Application
  end
end

World{MyWorld.new}
