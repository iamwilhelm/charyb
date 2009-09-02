# require this file makes it easy to require all models by default
Dir.glob(File.join(File.dirname(__FILE__), "models/*.rb")) do |model_file|
  require model_file.gsub(/#{File.extname(model_file)}/, "")
end

