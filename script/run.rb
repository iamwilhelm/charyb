#!/usr/bin/ruby

require 'config/initialize'
require 'charyb'

Store.open(Thoughtless::DATABASE_NAME) do |db|
  puts "Opened document store"
  Store.save_friends(db) 
end

