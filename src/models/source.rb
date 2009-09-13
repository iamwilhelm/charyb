require 'source/datasource'
require 'source/html'

module Source
  class << self
    # converts a content type to name of class
    def class_name_of(content_type)
      content_type[/(.*\/)?(.*)$/, 2].camelize
    end
  end
end
