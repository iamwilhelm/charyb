require 'friend/friend_store'

module Friend
  
  class Base
    include Friend::FriendStore

    attr_reader :service

    # friend is either a twitterer or a facebooker
    def initialize(friend)
      @service = :generic
      @friend = friend
      open_connection(Charyb::DEFAULT_DATABASE_NAME)
    end

    def to_s
      %(#{name} #{user_id}\n#{status}\n#{timestamp.to_s}\n\n)
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

end
