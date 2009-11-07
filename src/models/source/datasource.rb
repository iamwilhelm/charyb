require 'open-uri'
require 'openssl'
require 'net/http'

require 'core_ext/enumerable'

# we do this so we can visit SSL pages
Kernel::silence_warnings do
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
end

module Source

  # The base class for different datasources
  class Datasource < ActiveRecord::Base
    has_many :imported_tables, :dependent => :destroy

    validates_presence_of :url, :message => "can't be blank"
    validates_presence_of :content_type, :message => "can't be blank"

    class << self
      # converts a content type to name of class
      # see Datasource::content_type
      def class_name_of(content_type_str)
        content_type_str.gsub("/", "_").camelize
      end

      # The content_type for a particular class.
      # see Source::class_name_of
      def content_type
        self.name[/::(.*)$/, 1].underscore.gsub(/_/, '/')
      end
    end

    # Changes the type of class in DB when the content type changes
    def content_type=(new_content_type)
      write_attribute(:content_type, new_content_type)
    end

    # returns the title of the datasource, and if uninitialized,
    # returns the url of the datasource.
    def title
      (attributes["title"] == "Untitled Datasource") ? url : attributes["title"]
    end

    # helper function to make it easy to construct urls based on datasource type
    def url_type
      content_type.gsub("/", "_")
    end

    # shows the raw response body text of the datasource
    # 
    # NOTE this might end up being a long running process and will have to 
    # be a problem for web interface or for the crawler
    def response_body(reload = false)
      if reload or @body.nil?
        @body = open(url) { |f| f.read }
      else
        @body
      end
    end

    # returns the document for display
    def document
      raise Datasource::MethodOverride.new("document method needs to be overridden")
    end

    # returns the document for display
    def display
      raise Datasource::MethodOverride.new("display method needs to be overridden")
    end

    # extracts the data from the remote datasource
    def crawl
      raise Datasource::MethodOverride.new("crawl method needs to be overridden")
    end

    # see if this datasource needs to be crawled again
    def stale?(time = Time.now)
      updated_at < time
    end

    # raised when a polymorphic attribute needs to be overriden
    class MethodOverride < Exception; end
  end

end
