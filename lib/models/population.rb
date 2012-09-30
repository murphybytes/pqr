
class Population
  include Mongoid::Document
  has_many :samples
end
