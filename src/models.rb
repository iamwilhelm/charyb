# require this file makes it easy to require all models by default
Dir.glob(File.join(File.dirname(__FILE__), "models/*.rb")) do |model_file|
  puts model_file
  require model_file
end

