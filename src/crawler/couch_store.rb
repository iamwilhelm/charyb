require 'cgi'

require 'rubygems'
require 'couchrest'

module CouchStore
  
  class << self
    def open(db_name)
      db = CouchRest.database!("http://localhost:5984/#{db_name}")
      yield db
      return db
    rescue Errno::ECONNREFUSED => e
      $stderr.puts "Error: CouchDB is not running"
      exit
    end
    
    def setup(db)
      # user_view = db.get("_design/users")
      # puts user_view.inspect
      # db.save(View::users)
      # puts "Setted up the views"
    end
  end

  module View
    class << self
      def users
        { "_id" => "_design/users", 
          :views => {
            :status => {
              :map => %{
                function(doc) {
                  emit([doc.user_id, doc.service, doc.timestamp], doc);
                }
              }
            }
          }
        }
      end
    end
  end
end
