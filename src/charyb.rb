require 'social'
require 'friend'
require 'store'

def twitter_friends(session)
  session.friends.each do |friend|
    next if friend.status.nil? || friend.status.text.empty?
    yield Friend::Twitter.new(friend)
  end
rescue Exception => e
  puts e.inspect
end

def facebook_friends(session)
  friends = session.user.friends!(:name, :status) << session.user
  friends.each do |friend|
    next if friend.status.message.nil? || friend.status.message.empty?
    yield Friend::Facebook.new(friend)
  end
rescue Exception => e
  puts e.inspect
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
