require 'rubygems'
require 'facebooker'

module Friend

  class Facebook < Base
    attr_reader :service

    def initialize(friend)
      super
      @service = :facebook
    end

    def status
      @friend.status.message
    end

    def timestamp
      Time.at(@friend.status.time.to_i).utc
    end
  end

end
