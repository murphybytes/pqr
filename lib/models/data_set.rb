
class DataSet
  include Mongoid::Document
  has_many :samples
  has_many :thermal_storages
  field :name, type: String
  field :description, type: String
end
