require 'social'
require 'friend'
require 'store'

module Charyb

  class << self
    def start
      charyb = Charyb::Base.new
      charyb.crawl
    end
  end

  class Base
    def initialize(db_name = nil)
      @db_name = db_name || Charyb::DEFAULT_DATABASE_NAME
      @datasrcs = DataSource::SOURCES
    end

    def crawl
      all_friends do |friend|
        if friend.updated?
          puts friend.to_s
          friend.save
        end
      end
    end

    def all_friends
      friends = []

      Social::Twitter::login do |twitter_session|
        puts "logged into twitter"  
        puts "Getting twitter friends..."
        twitter_friends(twitter_session) { |friend| friends << friend }
      end

      Social::Facebook::login do |facebook_session|
        puts "logged into facebook"
        puts "Getting facebook friends..."
        facebook_friends(facebook_session) { |friend| friends << friend }
      end

      friends.sort.each do |friend|
        yield friend
      end
    end

    private
    
    def twitter_friends(session)
      session.friends.each do |friend|
        next if friend.status.nil? || friend.status.text.empty?
        yield Friend::Twitter.new(friend)
      end
    end

    def facebook_friends(session)
      friends = session.user.friends!(:name, :status) << session.user
      friends.each do |friend|
        next if friend.status.message.nil? || friend.status.message.empty?
        yield Friend::Facebook.new(friend)
      end
    end


  end

end

