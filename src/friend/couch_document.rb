module Friend
  
  module CouchDocument
    def to_doc
      { 
        :user_id => user_id,
        :service => service,
        :name => name,
        :timestamp => timestamp.xmlschema,
        :status => status
      }
    end
    
    def to_query
      {
        :user_id => user_id,
        :service => service,
        :timestamp => timestamp.xmlschema,
      }
    end
  end

end
