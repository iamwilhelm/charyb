require 'source/datasource'
Dir.glob(File.join(File.dirname(__FILE__) , "source", "*.rb")) do |model_file|
  require model_file
end

module Source
  class << self
    def sources
      [Source::TextHtml, Source::TextCsv]
    end
  end
end
