
class DataSet
  include Mongoid::Document
  has_many :populations
  field :name, type: String
  field :description, type: String
end
