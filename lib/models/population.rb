
class Population
  include Mongoid::Document
  has_many :samples
  belongs_to :data_set
  field :name, type: String
  field :description, type: String,
  field :units, type: String
end


