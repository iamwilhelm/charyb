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

#     include Datasource

#     # live birth and birth rates
#     source("http://www.infoplease.com/ipa/A0005067.html",
#            {
#              :column => proc { |doc| (doc/"table.sgmltable tr th") },
#              :record => proc { |doc| (doc/"table.sgmltable tr td") },
#            }, {
#              :clean_column => proc { |record| 
#                [ "year", "live_births", "birth_rates"]
#              },
#              :clean_record => proc { |record| 
#                year, live_births, birth_rates = record 
#                [ year.to_i, 
#                  rm_commas(live_births).to_i, 
#                  rm_commas(birth_rates).to_f, ]
#              },
#            })             
           

#     # live births by delivery method
#     source("http://www.infoplease.com/ipa/A0922187.html",
#            {
#              :column => proc { |doc| (doc/"table.sgmltable tr th") },
#              :record => proc { |doc| (doc/"table.sgmltable tr td") },
#            }, {
#              :clean_column => proc { |record| 
#                [ "year", "num_of_births", "vaginal_births", "cesarean_births", "cesarean_rate" ]
#              },
#              :clean_record => proc { |record| 
#                year, num_of_births, vaginal, cesarean, cesarean_rate = record 
#                [ year.to_i, 
#                  rm_commas(num_of_births).to_i, 
#                  rm_commas(vaginal).to_i,
#                  rm_commas(cesarean).to_i, 
#                  cesarean_rate.to_f, ]
#              },
#            })             

#     # median marriage age
#     source("http://www.infoplease.com/ipa/A0005061.html",
#            {
#              :column => proc { |doc| (doc/"table.sgmltable tr th") },
#              :record => proc { |doc| (doc/"table.sgmltable tr td") },
#            }, {
#              :clean_column => proc { |record| 
#                year, male_age, female_age = record
#                ["year", "male_median_marriage_age", "female_median_marriage_age"] 
#              },
#              :clean_record => proc { |record| 
#                year, male_age, female_age = record 
#                [year.to_i, rm_tags(male_age).to_f, rm_tags(female_age).to_f]
#              },
#            })

#     # Colonial population size
#     source("http://www.infoplease.com/ipa/A0004979.html",
#            {
#              :column => proc { |doc| (doc/"table.sgmltable tr th") },
#              :record => proc { |doc| (doc/"table.sgmltable tr td") },
#            }, {
#              :clean_column => proc { |record| ["year", "colonial_population"] },
#              :clean_record => proc { |record| 
#                year, pop = record 
#                [year.to_i, rm_commas(pop).to_i]
#              },
#            })
    
#     # US household by size
#     source("http://www.infoplease.com/ipa/A0884238.html",
#            { 
#              :column => proc { |doc| (doc/"table.sgmltable tr th") },
#              :record => proc { |doc| (doc/"table.sgmltable tr td") },
#            }, {
#              :clean_column => proc { |column|
#                year, households, _, avg_pop_per_household = column

#                # note that the columns are reordered here due to the 3rd th 
#                # being a spanning column header
#                numbers = { 1 => "one", 2 => "two", 3 => "three", 4 => "four", 5 => "five", 6 => "six", 7 => "seven" }
#                [ year.downcase, grep_spaces(condense_spaces(rm_tags(rm_parens(households)))).downcase] + 
#                  (1..7).map { |number| 
#                    if number == 7
#                      numbers[number] + "_or_more_person_households"
#                    else
#                      numbers[number] + "_person_households"
#                    end
#                  } + 
#                  [ "ave_pop_per_household" ]
#              },
#              :clean_record => proc { |record|
#                year, households = record
#                n_person_households = record[2..-2]
#                avg_pop_per_household = record[-1]

#                # we convert percentages to actual number by remultiplying the 
#                # percentage to the number of households
#                num_of_households = rm_commas(households).to_i
#                n_person_households.map! { |pph| (perc_to_f(pph) * num_of_households).round }

#                a = [ rm_spaces(rm_parens(year)).to_i, num_of_households ] + 
#                  n_person_households + 
#                  [ avg_pop_per_household.to_f ]
#                puts a.inspect
#                a
#              },
#              :collation => proc { |a, b| a.first <=> b.first }
#            })

#     # national census
#     source("http://www.infoplease.com/ipa/A0110380.html",
#            { 
#              :column => proc { |doc| (doc/"table.sgmltable tr th") },
#              :record => proc { |doc| (doc/"table.sgmltable tr td") },
#            }, { 
#              :clean_column => proc { |column|
#                year, population, land_area, population_per_land_area = column
#                [rm_spaces(year),
#                 rm_tags(population).chop.gsub(/\n+/, "_"),
#                 rm_tags(land_area.gsub(/,\s*/, "_")),
#                 rm_tags(rm_dots(population_per_land_area)),]
#              },
#              :clean_record => proc { |record|
#                year, population, land_area, population_per_land_area = record
#                [year.to_i, 
#                 rm_commas(rm_spaces(population)).to_i,
#                 rm_commas(land_area).to_i,
#                 population_per_land_area.to_f,]
#              },
#              :collation => proc { |a, b| a.first <=> b.first }
#            })
    
#     # Debt vs year  
#     source((1..5).map { |i| "http://www.treasurydirect.gov/govt/reports/pd/histdebt/histdebt_histo#{i}.htm" },
#            { :column => proc { |doc| (doc/"table.data1 th") },
#              :record => proc { |doc| (doc/"table.data1 td") }, 
#            }, { 
#              :clean_column => proc { |column|
#                date, debt = column
#                ["year", "debt"]
#              },
#              :clean_record => proc { |record|
#                date, amount = record
#                [date.match(/\/(\d+)\s*$/)[1].to_i, 
#                 rm_commas(rm_html_entities(amount).gsub(/\*/, "")).to_f]
#              },
#              :collation => proc { |a, b| a.first <=> b.first }, 
#            })
    
#   end
