require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'openssl'

require 'core_ext/enumerable'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

module Datasource
  class Base

    def initialize(uris, selectors, processors)
      @uris = uris.kind_of?(String) ? [uris] : uris
      @selectors = selectors
      @processors = processors
      @dataset = { :columns => [], :records => []}
      @updated_at = Time.now
    end
    
    def uri
      @uris.first
    end
    
    def stale?(time = Time.now)
      @updated_at < time
    end
    
    def crawl
      @uris.each do |uri|
        doc = Hpricot(open(uri))
        @dataset[:columns] = @selectors[:column].call(doc).map(&:inner_html)
        @dataset[:records] += @selectors[:record].call(doc).map(&:inner_html).
          map_slice(@dataset[:columns].size)
      end

      @dataset[:columns] = @processors[:clean_column].call(@dataset[:columns]) if @processors[:clean_column]
                              
      @dataset[:records].map!(&@processors[:clean_record])
      @dataset[:records].sort!(&@processors[:collation])
      @dataset[:records].each do |r| 
        @processors[:print].call(r) if @processors[:print]
        yield(@dataset[:columns], r) if block_given? 
      end
    end

    
  end
end

