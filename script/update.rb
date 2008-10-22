#!/usr/bin/ruby

require 'config/initialize'
require 'charyb'

include Friend::FriendStore

Store::open("thoughtless") do |db|
  hash = db.view("users/all")["rows"].each do |hash|
    puts hash.inspect
    record = db.get(hash["id"])
    
    time = Time.parse(record["timestamp"])
    record["timestamp"] = time.xmlschema
    puts record.inspect
    
    db.save(record)

  end
end
