#!/usr/bin/ruby

require 'csv'

module Charyb

  def Charyb.csv_to_table(content)
    out = "<html><head><title>a table</title></head><body><table border=\"1\">\n"
    #CSV.open('data/statab2008_0001_PopulationAndArea1790To2000_0_Data.csv', 'r') do |row|
    CSV.parse(content) do |row|
      row.map! { |x| x||='_' }
      out += "<tr><td>" + row.join("</td><td>") + "</td></tr>\n"
    end
    out += "</table></body></html>\n"
    return out
  end
end
