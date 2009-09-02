puts "required col!"

module Charyb
  class Col < ActiveRecord::Base
    belongs_to :source
  end
end
