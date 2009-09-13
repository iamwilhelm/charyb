# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090913111640) do

  create_table "cols", :force => true do |t|
    t.integer  "datasource_id",                                    :null => false
    t.string   "title",            :limit => 100,                  :null => false
    t.string   "data_type",                                        :null => false
    t.string   "units",                                            :null => false
    t.string   "multiplier",       :limit => 10,  :default => "1"
    t.string   "heading_selector",                                 :null => false
    t.string   "column_selector",                                  :null => false
    t.string   "converter"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "datasources", :force => true do |t|
    t.string   "url",             :limit => 2048,                                    :null => false
    t.string   "title",           :limit => 100,  :default => "Untitled Datasource"
    t.string   "type",            :limit => 20,                                      :null => false
    t.string   "content_type",                    :default => "text/html",           :null => false
    t.string   "description"
    t.datetime "last_crawled_at"
    t.datetime "last_changed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
