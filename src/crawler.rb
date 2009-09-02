require 'core_ext/string'

require 'source_tracker'
require 'couch_store'

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
        @dataware_name = dataware_name || Charyb::DEFAULT_DATA_WAREHOUSE_NAME
        @tracker = Charyb::SourceTracker.new
      end

      def crawl
        CouchStore.open(@dataware_name) do |@db|
          @tracker.datasources.each do |ds|
            next if !ds.stale?
            puts "Crawling #{ds.uri}"
            ds.crawl do |columns, record|
              columns = columns.map(&:downcase).map(&:underscorize)
              document = Hash[columns.zip(record)]
              pp document
              @db.save_doc(document)
            end
          end
        end
      end

    end

  end
end
