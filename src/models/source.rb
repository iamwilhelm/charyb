puts "required source!"

module Charyb
  class Source < ActiveRecord::Base
    has_many :cols
  end
end
