module Charyb
  class SourceTracker

    class << self

      def datasources
        Source::Datasource.find(:all)
      end

    end

  end  
end
