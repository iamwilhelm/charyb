module Models

  # model to represent the different data sources
  class Datasource < ActiveRecord::Base
    has_many :cols

    validates_presence_of :url, :message => "can't be blank"
    validates_presence_of :content_type, :message => "can't be blank"
  end

end
