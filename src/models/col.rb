module Models

  # model that represents columns and how to parse them in a datasource
  class Col < ActiveRecord::Base
    belongs_to :source
  end

end
