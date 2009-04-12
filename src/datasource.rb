require 'datasource/base'

module Datasource
  
  def self.included(mod)
    mod.extend(ClassMethods)
  end  
  
  module ClassMethods
    def source(uris, selectors = {}, processors = {})
      datasources << Datasource::Base.new(uris, selectors, processors)
    end
    
    def datasources
      @@_datasources ||= []
    end
  end
  
end

