require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'openssl'

require 'core_ext/enumerable'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

module Models

  # model to represent the different data sources
  class Datasource < ActiveRecord::Base
    has_many :cols

    validates_presence_of :url, :message => "can't be blank"
    validates_presence_of :content_type, :message => "can't be blank"

    def title
      (attributes["title"] == "Untitled Datasource") ? url : attributes["title"]
    end

    # see if this datasource needs to be crawled again
    def stale?(time = Time.now)
      updated_at < time
    end

    def crawl
      doc = Hpricot(open(uri))

      # clean columns and records
      cols.each do |col|
        heading = (doc/col.heading_selector).inner_html
        (doc/col.column_selector).each do |row|
          row.inner_html
        end
      end

      @dataset[:columns] = @selectors[:column].call(doc).map(&:inner_html)
      if @processors[:clean_column]
        @dataset[:columns] = @processors[:clean_column].call(@dataset[:columns])
      end
      
      @dataset[:records] += @selectors[:record].call(doc).map(&:inner_html).map_slice(@dataset[:columns].size)
                              
      @dataset[:records].map!(&@processors[:clean_record])
      @dataset[:records].sort!(&@processors[:collation])
      @dataset[:records].each do |r| 
        @processors[:print].call(r) if @processors[:print]
        yield(@dataset[:columns], r) if block_given? 
      end
    end

  end

end
