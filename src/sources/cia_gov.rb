module CiaGov

  def self.included(mod)
    mod.extend(ClassMethods)
  end

  module ClassMethods
    def clean_cia_column
      proc { |columns|
        rank, country, attribute, updated_at = columns
        attribute = attribute.gsub(/\s+/, " ").gsub(/^\s/, "").gsub(/\s$/, "")
        attribute, units = attribute.split(/<.*>/)
        [country, attribute, updated_at]
      }
    end
    
    def clean_cia_record
      proc { |record|
        rank, country, attribute, updated_at = record.map { |r|
          md = r.match(/<.*>(.*)<\/.*>/) 
          md.nil? ? r : md[1]
        }.map { |r| r.gsub(/^\s+/, "").gsub(/\s+$/, "") }
        a = [country, attribute.gsub(/,/, "").to_f, updated_at]
      }
    end
  end
    
#     # country vs population
#     # source("test/datasources/cia.gov/2119rank.html",
#     source("https://www.cia.gov/library/publications/the-world-factbook/rankorder/2119rank.html",
#            { :column => proc { |doc| (doc/"table th.smalltext") }, 
#              :record => proc { |doc| (doc/"table#rankorder table table tr") },
#              :skip => 2 },
#            { :clean_column => clean_cia_column,
#              :clean_record => clean_cia_record,
#              :collation => proc { |a, b| a.first <=> b.first },
#            })

#     # country vs birth rate
#     source("https://www.cia.gov/library/publications/the-world-factbook/rankorder/2054rank.html",
#     # source("test/datasources/cia.gov/2054rank.html",
#            { :column => proc { |doc| (doc/"table th.smalltext") }, 
#              :record => proc { |doc| (doc/"table#rankorder table table tr") },
#            },
#            { :clean_column => clean_cia_column,
#              :clean_record => clean_cia_record,
#              :collation => proc { |a, b| a.first <=> b.first },
#            })

#     # country vs death rate
#     source("https://www.cia.gov/library/publications/the-world-factbook/rankorder/2066rank.html",
#     # source("test/datasources/cia.gov/2066rank.html",
#            { :column => proc { |doc| (doc/"table th.smalltext") }, 
#              :record => proc { |doc| (doc/"table#rankorder table table tr") },
#            },
#            { :clean_column => clean_cia_column,
#              :clean_record => clean_cia_record,
#              :collation => proc { |a, b| a.first <=> b.first },
#            })

#     # country vs population growth
#     source("https://www.cia.gov/library/publications/the-world-factbook/rankorder/2002rank.html",
#     # source("test/datasources/cia.gov/2002rank.html",
#            { :column => proc { |doc| (doc/"table th.smalltext") }, 
#              :record => proc { |doc| (doc/"table#rankorder table table tr") },
#            },
#            { :clean_column => clean_cia_column,
#              :clean_record => clean_cia_record,
#              :collation => proc { |a, b| a.first <=> b.first },
#            })

end
