module Models

  # model to represent the different data sources
  class Datasource < ActiveRecord::Base
    has_many :cols
  end

end
