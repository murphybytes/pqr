
class Population
  include Mongoid::Document
  ALLOWED_TYPES = ['temperature', 'power units']

  has_many :samples
  belongs_to :data_set
  field :name, type: String
  field :description, type: String
  field :units, type: String
  field :value_type, type: String

  validates_inclusion_of :value_type :in ALLOWED_TYPES
end


