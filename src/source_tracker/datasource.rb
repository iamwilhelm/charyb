require 'datasource/base'
require 'datasource/string_filters'

module Datasource
  
  def self.included(mod)
    mod.extend(ClassMethods)
  end  
  
  module ClassMethods
    include Datasource::StringFilters

    def source(uris, selectors = {}, processors = {})
      datasources << Datasource::Base.new(uris, selectors, processors)
    end
    
    def datasources
      @@_datasources ||= []
    end
  end
  
end

