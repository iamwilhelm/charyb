#!/usr/bin/ruby

require 'config/initialize'
require 'charyb'

begin
  Charyb.start
rescue Exception => e
  puts e.backtrace
  exit 1
end
