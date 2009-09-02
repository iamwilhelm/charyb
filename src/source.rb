require 'active_record'

module Charyb
  class Source < ActiveRecord::Base
    has_many :cols
  end
end
