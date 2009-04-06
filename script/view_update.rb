#!/usr/bin/ruby

require "config/initialize"
require "charyb"

Store.open(Charyb::DEFAULT_DATABASE_NAME) do |db|
  puts "Opened document store"
  Store.setup(db)
  puts "Updated view documents"
end

  
