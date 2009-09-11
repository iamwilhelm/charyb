require 'friend/couch_document'

module Friend

  module FriendStore
    include Friend::CouchDocument
    
    def open_connection(db_name)
      Store.open(db_name) do |@@db|
        yield if block_given?
      end
    end
    
    def save
      @@db.save(to_doc)
    end

    # need to use DSL to be able to specify the views
    def user_status
      # TODO should use couch document's to_query
      url = %Q{users/status?key=[#{user_id},"#{service}","#{timestamp.xmlschema}"]}
      @@db.view(URI::escape(url))
    end

    def updated?
      # if no unique statuses, friend has new status update, 
      # which means he/she updated
      user_status["rows"].empty?
    end

  end

end
