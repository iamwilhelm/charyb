require 'source/datasource'
Dir.glob(File.join(File.dirname(__FILE__) , "source", "*.rb")) do |model_file|
  require model_file
end

module Source
  class << self
    # converts a content type to name of class
    def class_name_of(content_type)
      content_type[/(.*\/)?(.*)$/, 2].camelize
    end
  end
end
