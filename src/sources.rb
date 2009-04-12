require 'datasource'

module Charyb
  class Sources
    include Datasource
    
    # debt vs year  
    # source((1..5).map { |i| "http://www.treasurydirect.gov/govt/reports/pd/histdebt/histdebt_histo#{i}.htm" },
    source((1..5).map { |i| "test/datasources/treasury.gov/histdebt_histo#{i}.htm" },
           { :column => proc { |doc| (doc/"table.data1 th") },
             :record => proc { |doc| (doc/"table.data1 td") }, 
           },
           { :clean => proc { |record|
               date, amount = record
               [date.match(/\/(\d+)\s*$/)[1].to_i, 
                amount.gsub(/&\w+;/, "").gsub(/\*/, "").gsub(/,/, "").to_f]
             },
             :collation => proc { |a, b| a.first <=> b.first }, 
           })
    
    # country vs population
    # source("https://www.cia.gov/library/publications/the-world-factbook/rankorder/2119rank.html",
    source("test/datasources/cia.gov/2119rank.html",
           { :column => proc { |doc| (doc/"table td div.FieldLabel") }, 
             :record => proc { |doc| (doc/"table td > table tr:gt(1) td") },
           },
           { :clean => proc { |record|
               rank, country, population, updated_at = record.map { |r|
                 md = r.match(/<.*>(.*)<\/.*>/) 
                 md.nil? ? r : md[1]
               }.map { |r| r.gsub(/^\s+/, "").gsub(/\s+$/, "") }
               a = [country, population.gsub(/,/, "").to_i, updated_at]
             },
             :collation => proc { |a, b| a.first <=> b.first },
           })

    # country vs birth rate
    # source("https://www.cia.gov/library/publications/the-world-factbook/rankorder/2054rank.html",
    source("test/datasources/cia.gov/2054rank.html",
           { :column => proc { |doc| (doc/"table td div.FieldLabel") }, 
             :record => proc { |doc| (doc/"table td > table tr:gt(1) td") },
           },
           { :clean => proc { |record|
               rank, country, birth_rate, updated_at = record.map { |r|
                 md = r.match(/<.*>(.*)<\/.*>/) 
                 md.nil? ? r : md[1]
               }.map { |r| r.gsub(/^\s+/, "").gsub(/\s+$/, "") }
               a = [country, birth_rate.gsub(/,/, "").to_f, updated_at]
             },
             :collation => proc { |a, b| a.first <=> b.first },
           })

    # country vs death rate
    # source("https://www.cia.gov/library/publications/the-world-factbook/rankorder/2066rank.html",
    source("test/datasources/cia.gov/2066rank.html",
           { :column => proc { |doc| (doc/"table td div.FieldLabel") }, 
             :record => proc { |doc| (doc/"table td > table tr:gt(1) td") },
           },
           { :clean => proc { |record|
               rank, country, death_rate, updated_at = record.map { |r|
                 md = r.match(/<.*>(.*)<\/.*>/) 
                 md.nil? ? r : md[1]
               }.map { |r| r.gsub(/^\s+/, "").gsub(/\s+$/, "") }
               a = [country, death_rate.gsub(/,/, "").to_f, updated_at]
             },
             :collation => proc { |a, b| a.first <=> b.first },
           })

    # country vs population growth
    # source("https://www.cia.gov/library/publications/the-world-factbook/rankorder/2002rank.html",
    source("test/datasources/cia.gov/2002rank.html",
           { :column => proc { |doc| (doc/"table td div.FieldLabel") }, 
             :record => proc { |doc| (doc/"table td > table tr:gt(1) td") },
           },
           { :clean => proc { |record|
               rank, country, pop_rate, updated_at = record.map { |r|
                 md = r.match(/<.*>(.*)<\/.*>/) 
                 md.nil? ? r : md[1]
               }.map { |r| r.gsub(/^\s+/, "").gsub(/\s+$/, "") }
               a = [country, pop_rate.gsub(/,/, "").to_f, updated_at]
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
