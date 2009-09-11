require 'rubygems'
require 'twitter'

module Friend

  class Twitter < Base
    attr_reader :service

    def initialize(friend)
      super
      @service = :twitter
    end

    def status
      @friend.status.text
    end

    def timestamp
      Time.parse(@friend.status.created_at).utc
    end
  end

end
