require 'config/initialize'

require 'core_ext/string'

require 'source_tracker'

module Charyb
  # The background process that crawls 
  module Crawler
    
    class << self
      def start
        Charyb::Crawler::Base.new.crawl
      end
    end
    
    class Base
      def initialize(dataware_name = nil)
        @dataware_name = dataware_name || Charyb::DEFAULT_DATAWAREHOUSE_NAME
      end
      
      def crawl
        # open up Redis through Tyra
          Charyb::SourceTracker.datasources.each do |ds|
            next if !ds.stale?
            puts "Crawling #{ds.url}"
          end

      end

    end

  end
end
