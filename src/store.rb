require 'cgi'

require 'rubygems'
require 'couchrest'

module Store
  class << self
    def open(db_name)
      db = CouchRest.database!("http://localhost:5984/#{db_name}")
      yield db
    rescue Errno::ECONNREFUSED => e
      $stderr.puts "Error: CouchDB is not running"
      exit
    end
    
    def setup(db)
      #user_view = db.get("_design/users")
      #puts user_view.inspect
      db.save(View::users)
      puts "Setted up the views"
    end

    def save_friends(db)
      all_friends do |friend|
        if friend_updated?(friend, db)
          puts friend.to_s
          db.save(friend.to_doc)
        end
      end
    end

    def unique_status(friend, db)
      # must be an easier way to query friends through couchrest
      url = %Q{users/status?key=[#{friend.user_id},"#{friend.service}","#{friend.timestamp}"]}
      db.view(URI::escape(url))
    end

    def friend_updated?(friend, db)
      # if no unique statuses, friend has new status update, 
      # which means he/she updated
      unique_status(friend, db)["rows"].empty?
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
