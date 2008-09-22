#!/usr/bin/ruby

require "config/initialize"

Store.open(Thoughtless::DATABASE_NAME) do |db|
  puts "Opened document store"
  Store.setup(db)
  puts "Updated view documents
end

  
