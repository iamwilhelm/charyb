require 'source/string_filters'

module Source

  # A datasource that is an html table that needs to be parsed using css selectors 
  # and cleaned in order to extract the data they contain
  class TextHtml < Datasource
    include Source::StringFilters

    # returns a filtered response body
    def response_body(reload = false)
      rm_script_tags(super(reload))
    end

    # encapulates a response body in an Hpricot object so it can be 
    # traversed
    def document(reload = false)
      @doc = Hpricot(response_body(reload))
    end
    
    # displays datasource for human intervention of data extraction
    def display
      (@doc/"body").inner_html
    end
    
    # retrieve and extract data from the datasource
    def crawl
      cols.map do |col|
        # let's grab each column and the data for that column
        heading = (document/col.heading_selector).inner_html
        data = (document/col.column_selector).map { |row| row.inner_html }
        [heading, data]
      end.transpose.tap do |dm|
        # let's transpose the matrix and grab the headers
        @headers = dm.slice(0)
      end.slice(1..-1).each do |row|
        # and the we take all the data and we yield each row as
        # a hash of headers matched with their column value for this row
        yield Hash[*@headers.zip(row)]
      end
    end
  end

end
