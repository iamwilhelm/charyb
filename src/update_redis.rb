#require 'lib/redis'

def underscore(str)
  return str.gsub(/ /, "_")
end

def quote(str)
  return '"' + str.chomp + '"'
end

module Charyb

  def Charyb.update_redis(datasource, imported_table, data)
    
    #File.open("output.csv", "w") do |pipe|
    IO.popen("python script/importer.py -n 0", "w+") do |pipe|

      # write header stuff
      pipe.write("name, \"" + imported_table.table_heading + "\"\n")
      pipe.write("descr, \"" + imported_table.descr + "\"\n")
      pipe.write("source, \"" + datasource.title + "\"\n")
      pipe.write("url, \"" + datasource.url + "\"\n")
      pipe.write("license, Unknown\n")
      pipe.write("publishDate, \"" + imported_table.published_at.to_s() + "\"\n")
      pipe.write("units, " + imported_table.units + "\n")

      otherdims = imported_table.other_dims.split(",")
      while not otherdims.empty?
        pipe.write("otherDims, " + otherdims.shift + "," + otherdims.shift + "\n")
      end

      pipe.write("default, \"" + imported_table.default_dim + "\"\n")
      pipe.write("colLabel, \"" + imported_table.col_heading + "\"\n")
      pipe.write("rowLabel, \"" + imported_table.row_heading + "\"\n")
      col_labels = imported_table.col_labels_content.map{|s|quote(s)}
      pipe.write("cols, " + col_labels.join(",")  + "\n\n")

      # write data
      numCols = col_labels.length
      data = data.split("\n").map{|s|quote(s.gsub(",",""))};
      row_labels = imported_table.row_labels_content.map{|s|quote(s)};
      (0...row_labels.length).each do |rr|
        pipe.write(row_labels[rr] + ", " + data[rr * numCols, numCols].join(",") + "\n")
      end

      pipe.close_write
      #    fout.write pipe.read
    end
  end
end
