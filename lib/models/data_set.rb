
class DataSet
  include Mongoid::Document
  has_many :samples
  field :name, type: String
  field :description, type: String
end
