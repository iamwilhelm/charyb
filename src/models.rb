# initialize connection to source tracking database
require 'rubygems'
require 'active_record'

# require all model files
Dir.glob(File.join(File.dirname(__FILE__), "models/*.rb")) do |model_file|
  require model_file.gsub(/#{File.extname(model_file)}/, "")
end

module Charyb
  puts "activating active_record logger"
  ActiveRecord::Base.logger = Logger.new(DATASOURCES_LOG_PATH)

  puts "connecting to db at #{DATASOURCES_PATH}"
  @connection = ActiveRecord::Base.establish_connection(:adapter => "sqlite3",
                                                        :dbfile => DATASOURCES_PATH)
end

