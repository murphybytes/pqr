
class Sample
  include Mongoid::Document

  belongs_to :data_set 

  field :temperature, type: BigDecimal
  field :power_units, type: BigDecimal
  field :timestamp, type: DateTime


end
