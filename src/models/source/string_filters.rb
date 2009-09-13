module Source

  # These are methods that clean strings and remove unwanted parts of a string
  # mostly useful for cleaning up scraped strings and text
  module StringFilters

    # removes all tags
    def rm_tags(str)
      rm_single_tags(str).gsub(/<.*>[^<>].*<\/.*>/, "")
    end

    # removes only self closing tags
    def rm_single_tags(str)
      str.gsub(/<[^<>]*\/>/, "")
    end

    # removes all html entities
    def rm_html_entities(str)
      str.gsub(/&\w+;/, "")
    end

    # removes parenthesis and the stuff inside them
    def rm_parens(str)
      str.gsub(/\(.*\)/, "")
    end

    # removes all commas
    def rm_commas(str)
      str.gsub(/,\s*/, "")
    end

    # removes all dots
    def rm_dots(str)
      str.gsub(/\./, "")
    end

    # removes all spaces
    def rm_spaces(str)
      str.gsub(/\s+/, "")
    end

    # compress a sequence of whitespace into one space
    def condense_spaces(str)
      str.gsub(/\s+/, " ")
    end

    # compress a sequence of whitespace into underscore
    def grep_spaces(str)
      str.gsub(/\s+/, "_")
    end

    # convert string to percent
    def perc_to_f(str)
      str.gsub(/%/, "").to_f / 100.0
    end

    # filter out certain tags
    def rm_script_tags(text)
      puts text.length
      text.gsub!(/<script.*>.*<\/script>/, "")
      puts text.length
      text.gsub!(/<script.*\/>/, "")
      puts text.length
      text.gsub!(/<object.*>.*<\/object>/, "")
      puts text.length
      text.gsub!(/<embed.*>.*<\/embed>/, "")
      puts text.length
      return text
    end
  end

end
