#require 'social'
#require 'friend'

require 'core_ext/string'

require 'sources'
require 'couch_store'

module Charyb

  class << self
    def start
      Charyb::Base.new.crawl
    end
  end
  
  class Base
    def initialize(db_name = nil)
      @db_name = db_name || Charyb::DEFAULT_DATABASE_NAME
      @datasources = Charyb::Sources::datasources
    end

    def crawl
      CouchStore.open(@db_name) do |@db|
        @datasources.each do |ds|
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

