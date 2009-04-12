module Enumerable
  def map_slice(n)
    array = []
    each_slice(n) { |s| array << (block_given? ? yield(s) : s) }
    return array
  end  
end
