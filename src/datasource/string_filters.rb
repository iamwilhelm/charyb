module Datasource

  # These are methods that clean strings and remove unwanted parts of a string
  # mostly useful for cleaning up scraped strings and text
  module StringFilters
    # module_functions

    def rm_tags(str)
      str.gsub(/<.*\/>/, "").gsub(/<.*>.*<\/.*>/, "")
    end
    
    def rm_html_entities(str)
      str.gsub(/&\w+;/, "")
    end

    def rm_commas(str)
      str.gsub(/,\s*/, "")
    end

    def rm_dots(str)
      str.gsub(/\./, "")
    end

    def rm_spaces(str)
      str.gsub(/\s+/, "")
    end

    def grep_spaces(str)
      str.gsub(/\s+/, "_")
    end

  end

end
