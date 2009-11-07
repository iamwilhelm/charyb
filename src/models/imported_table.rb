# model that represents tables imported from a url
class ImportedTable < ActiveRecord::Base
  belongs_to :datasource
end
