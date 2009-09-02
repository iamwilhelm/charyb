module Models

  # model to represent the different data sources
  class DataSource < ActiveRecord::Base
    has_many :cols
  end

end
