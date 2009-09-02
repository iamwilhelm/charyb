require 'active_record'

module Charyb
  class Col < ActiveRecord::Base
    belongs_to :source
  end
end
