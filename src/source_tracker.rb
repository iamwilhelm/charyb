require 'source'
require 'col'

module Charyb
  class SourceTracker

    def initialize
      setup
    end

    def datasources
      Charyb::Datasource.find(:all)
    end
    
    # Sets up the appropriate tables to store the data sources
    def setup

      ActiveRecord::Schema.define do
        if Datasource.table_exists?
          puts "creating sources table"
          # keeping track of where our sources of data are and their stats
          create_table :datasources do |t|
            # Unique identifier for each source
            t.string :url, :limit => 2048, :null => false
            # Gives us a way to know how to process data on the resource
            t.string :mime_type, :default => "text/html", :null => false
            # A short description to help us remember what data's here
            t.string :description, :limit => 255
            # The time last crawled
            t.datetime :last_crawled_at
            # The time source last changed
            t.datetime :last_changed_at
            # timestamps for this db record
            t.timestamps
          end 
        end
        
        if Col.table_exists?
          puts "creating cols table"
          # for each source, how do we parse and clean it?
          create_table :cols do |t|
            # ties the modifier to the resource
            t.references :source, :null => false
            # the column heading and title for this column
            t.string :title, :limit => 100
            # the data type for the column, to know how to treat it
            t.string :data_type, :null => false
            # the units for all the data in this column
            t.string :units, :null => false
            # column position for this data 
            t.integer :column_position, :null => false
            # how to clean string input from parsing into a format we want
            t.string :converter
            # timestamps for this db record
            t.timestamps
          end 
        end
      end

    end

  end  
end
