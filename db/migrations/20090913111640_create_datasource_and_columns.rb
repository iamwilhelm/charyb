class CreateDatasourceAndColumns < ActiveRecord::Migration
  def self.up
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
      # the CSS expression or XPATH to find the heading
      t.string :heading_selector, :limit => 255, :null => false
      # the CSS expression or XPATH to find the columns
      t.string :column_selector, :limit => 255, :null => false              
      # how to clean string input from parsing into a format we want
      t.string :converter
      # the data type for the column, to know how to treat it
      t.string :data_type, :null => false
      # the units for all the data in this column
      t.string :units, :null => false
      # Any extraneous notes about the column as foot notes
      t.text :notes
      # timestamps for this db record
      t.timestamps
    end 
  end
  
  def self.down
    drop_table :datasources
    drop_table :cols
  end
end
