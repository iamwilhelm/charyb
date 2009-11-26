require 'csv_to_table'

module Source

  # A datasource that's a CSV file that needs to be parsed 
  # and cleaned in order to extract the data they contain
  class TextPlain < Datasource
    
    # returns the raw response body from the http request that downloaded 
    # the CSV file
    def response_body(reload = false)
      # do any filtering on the raw text here
      super(reload)
    end

    # encapsulates a response body in a wrapper object (like FasterCSV) that 
    # makes it easier to traverse the data
    #
    # if reload is true, then we load it again.  if false, we use the memoized copy
    # stored in an attribute
    def document(reload = false)
      @doc = Charyb.csv_to_table(response_body)
    end

    def display
      @doc
    end

    # retrieve and extract data from the datasource and yield rows as a hash
    # containing the data
    def crawl
    end

  end
end
