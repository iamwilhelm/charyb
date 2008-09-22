require 'rubygems'
require 'facebooker'
require 'twitter'

module Friend
  
  module CouchDocument
    def to_doc
      { 
        :user_id => user_id,
        :service => service,
        :name => name,
        :timestamp => timestamp.to_s,
        :status => status
      }
    end
    
    def to_query
      {
        :user_id => user_id,
        :service => service,
        :timestamp => timestamp.to_s,
      }
    end
  end

  class Base
    include CouchDocument

    attr_reader :service, "generic"

    def initialize(friend)
      @friend = friend
    end

    def to_s
      %(#{name} #{user_id}\n#{status}\n#{timestamp.utc.to_s}\n\n)
    end

    def <=>(other)
      self.timestamp <=> other.timestamp
    end

    def user_id
      @friend.id.to_i
    end

    def name
      @friend.name
    end
  end

  class Twitter < Base
    attr_reader :service

    def initialize(friend)
      super
      @service = "twitter"
    end

    def status
      @friend.status.text
    end

    def timestamp
      Time.parse(@friend.status.created_at).utc
    end
  end

  class Facebook < Base
    attr_reader :service

    def initialize(friend)
      super
      @service = "facebook"
    end

    def status
      @friend.status.message
    end

    def timestamp
      Time.at(@friend.status.time.to_i).utc
    end
  end

end
