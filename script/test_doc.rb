#!/usr/bin/ruby

require 'rubygems'
require 'hpricot'
require 'open-uri'

doc = Hpricot(open("http://www.infoplease.com/ipa/A0884238.html"))
puts (doc/"table.sgmltable tr th").map(&:inner_html).inspect

#doc = Hpricot(open("http://www.treasurydirect.gov/govt/reports/pd/histdebt/histdebt_histo1.htm"))
#puts (doc/"table.data1 td")
