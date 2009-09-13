class Object
  if Object.method_defined?("tap")
    # This function allows you to tap inside of an object during a 
    # method chain, to either examine the state of the object 
    # or manipulate it.  It is similar to returning()
    #
    #   arr.transpose.tap { |a| puts a }.join("-")
    #
    # This method is available in ruby 1.9+, but not in older versions
    def tap
      yield self
      self
    end
  end
end
