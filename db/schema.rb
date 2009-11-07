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

ActiveRecord::Schema.define(:version => 20091105205200) do

  create_table "datasources", :force => true do |t|
    t.string   "title",           :limit => 100,  :default => "Untitled Datasource"
    t.string   "url",             :limit => 2048,                                    :null => false
    t.string   "content_type",                    :default => "text/html",           :null => false
    t.datetime "last_crawled_at"
    t.datetime "last_changed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "imported_tables", :force => true do |t|
    t.integer  "datasource_id",                                      :null => false
    t.string   "table_heading",      :limit => 100,                  :null => false
    t.string   "col_heading",        :limit => 100,                  :null => false
    t.string   "row_heading",        :limit => 100,                  :null => false
    t.string   "other_dims"
    t.string   "descr"
    t.datetime "published_at"
    t.text     "notes"
    t.string   "is_numeric",         :limit => 1,   :default => "1", :null => false
    t.string   "units",                                              :null => false
    t.string   "multiplier",                        :default => "1"
    t.string   "converter"
    t.string   "col_labels_one",     :limit => 100,                  :null => false
    t.string   "col_labels_two",     :limit => 100,                  :null => false
    t.string   "col_labels_content",                                 :null => false
    t.string   "row_labels_one",     :limit => 100,                  :null => false
    t.string   "row_labels_two",     :limit => 100,                  :null => false
    t.string   "row_labels_content",                                 :null => false
    t.string   "data_one",           :limit => 100,                  :null => false
    t.string   "data_two",           :limit => 100,                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
