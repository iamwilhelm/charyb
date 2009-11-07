class ImportByTable < ActiveRecord::Migration
  def self.up
    # drop the old tables (any data in them will be useless)
    drop_table :datasources
    drop_table :cols

    # for each url
    create_table :datasources do |t|
      # Optional title
      t.string :title, :limit => 100, :default => "Untitled Datasource", :null => true
      # Unique identifier for each source
      t.string :url, :limit => 2048, :null => false
      # Gives us a way to know how to process data on the resource
      t.string :content_type, :default => "text/html", :null => false
      # the last time we crawled this url
      t.datetime :last_crawled_at
      # the last time crawling this url changed our data
      t.datetime :last_changed_at
      # timestamps for this db record
      t.timestamps
    end 

    # for each table
    create_table :imported_tables do |t|
      # ties the modifier to the resource
      t.references :datasource, :null => false
      # the table heading
      t.string :table_heading, :limit => 100, :null => false
      # the heading that describes all columns
      t.string :col_heading, :limit => 100, :null => false
      # the heading that describes all rows
      t.string :row_heading, :limit => 100, :null => false
      # A short description to help us remember what data's here
      t.string :descr, :limit => 255
      # the date this data was published
      t.datetime :published_at
      # any notes
      t.text :notes

      # each item in this section can be a single value or csv for each col
      # tells if the values are numeric (can be aggregated)
      t.string :is_numeric, :limit => 1, :null => false, :default => 1
      # units after scaling
      t.string :units, :null => false
      # the multiplier for scaling the data to the proper units (can be in sci notation)
      t.string :multiplier, :null => true, :default => 1
      # how to clean string input from parsing into a format we want
      t.string :converter, :limit => 255

      # XPATH to one corner of the column header labels
      t.string :col_labels_one, :limit => 100, :null => false
      # XPATH to the other corner of the column header labels
      t.string :col_labels_two, :limit => 100, :null => false
      # csv text of col header labels
      t.string :col_labels_content, :null => false

      # XPATH to one corner of the row header labels
      t.string :row_labels_one, :limit => 100, :null => false
      # XPATH to the other corner of the row header labels
      t.string :row_labels_two, :limit => 100, :null => false
      # csv text of row header labels
      t.string :row_labels_content, :null => false

      # XPATH to one corner of the data
      t.string :data_one, :limit => 100, :null => false
      # XPATH to the other corner of the data
      t.string :data_two, :limit => 100, :null => false
      # csv text of data
      t.string :data_content, :null => false

      # timestamps for this db record
      t.timestamps
    end 
  end
  
  def self.down
    drop_table :source_urls
    drop_table :imported_tables

    # keeping track of where our sources of data are and their stats
    create_table :datasources do |t|
      # Unique identifier for each source
      t.string :url, :limit => 2048, :null => false
      # Optional title
      t.string :title, :limit => 100, :default => "Untitled Datasource", :null => true
      # Type of datasource dictacts how to process it
      t.string :type, :limit => 20, :null => false
      # Gives us a way to know how to process data on the resource
      t.string :content_type, :default => "text/html", :null => false
      # A short description to help us remember what data's here
      t.string :description, :limit => 255
      # The time last crawled
      t.datetime :last_crawled_at
      # The time source last changed
      t.datetime :last_changed_at
      # timestamps for this db record
      t.timestamps
    end 

    # for each source column, how do we parse and clean it?
    create_table :cols do |t|
      # ties the modifier to the resource
      t.references :datasource, :null => false
      # the column heading and title for this column
      t.string :title, :limit => 100, :null => false
      # the data type for the column, to know how to treat it
      t.string :data_type, :null => false
      # the units for all the data in this column
      t.string :units, :null => false
      # the multiplier for units to the value in the columns (can be in sci notation)
      t.string :multiplier, :limit => 10, :null => true, :default => 1
      # the CSS expression or XPATH to find the heading
      t.string :heading_selector, :limit => 255, :null => false
      # the CSS expression or XPATH to find the columns
      t.string :column_selector, :limit => 255, :null => false              
      # how to clean string input from parsing into a format we want
      t.string :converter
      # Any extraneous notes about the column as foot notes
      t.text :notes
      # timestamps for this db record
      t.timestamps
    end 
  end
end
