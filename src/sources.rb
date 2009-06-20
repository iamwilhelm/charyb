require 'datasource'
require 'datasource/string_filters'

require 'sources/cia_gov'

module Charyb
  class Sources
    include Datasource
    include CiaGov

    class << self
      include Datasource::StringFilters
    end
    
    # national census
    source("http://www.infoplease.com/ipa/A0110380.html",
           { 
             :column => proc { |doc| (doc/"table#A0110381 tr th") },
             :record => proc { |doc| (doc/"table#A0110381 tr td") },
           }, { 
             :clean_column => proc { |column|
               year, population, land_area, population_per_land_area = column
               [rm_spaces(year),
                rm_tags(population).chop.gsub(/\n+/, "_"),
                rm_tags(land_area.gsub(/,\s*/, "_")),
                rm_tags(rm_dots(population_per_land_area)),]
             },
             :clean_record => proc { |record|
               year, population, land_area, population_per_land_area = record
               [year.to_i, 
                rm_commas(rm_spaces(population)).to_i,
                rm_commas(land_area).to_i,
                population_per_land_area.to_f,]
             },
             :collation => proc { |a, b| a.first <=> b.first }
           })
    
    # US household by size
    # http://www.infoplease.com/ipa/A0884238.html

    # debt vs year  
    source((1..5).map { |i| "http://www.treasurydirect.gov/govt/reports/pd/histdebt/histdebt_histo#{i}.htm" },
    # source((1..5).map { |i| "test/datasources/treasury.gov/histdebt_histo#{i}.htm" },
           { :column => proc { |doc| (doc/"table.data1 th") },
             :record => proc { |doc| (doc/"table.data1 td") }, 
           }, { 
             :clean_column => proc { |column|
               date, debt = column
               ["year", debt]
             },
             :clean_record => proc { |record|
               date, amount = record
               [date.match(/\/(\d+)\s*$/)[1].to_i, 
                rm_commas(rm_html_entities(amount).gsub(/\*/, "")).to_f]
             },

             :collation => proc { |a, b| a.first <=> b.first }, 
           })

  end
  
end

#     def all_friends
#       friends = []

#       Social::Twitter::login do |twitter_session|
#         puts "logged into twitter"  
#         puts "Getting twitter friends..."
#         twitter_friends(twitter_session) { |friend| friends << friend }
#       end

#       Social::Facebook::login do |facebook_session|
#         puts "logged into facebook"
#         puts "Getting facebook friends..."
#         facebook_friends(facebook_session) { |friend| friends << friend }
#       end

#       friends.sort.each do |friend|
#         yield friend
#       end
#     end

#     private
    
#     def twitter_friends(session)
#       session.friends.each do |friend|
#         next if friend.status.nil? || friend.status.text.empty?
#         yield Friend::Twitter.new(friend)
#       end
#     end

#     def facebook_friends(session)
#       friends = session.user.friends!(:name, :status) << session.user
#       friends.each do |friend|
#         next if friend.status.message.nil? || friend.status.message.empty?
#         yield Friend::Facebook.new(friend)
#       end
#     end
