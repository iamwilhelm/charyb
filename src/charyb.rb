#require 'social'
#require 'friend'
#require 'store'

require 'sources'

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
      @datasources.each do |ds|
        next if !ds.stale?
        puts "Crawling #{ds.uri}"
        ds.crawl do |record|
          puts "=> #{record.inspect}"
        end
      end
    end

  end

end

