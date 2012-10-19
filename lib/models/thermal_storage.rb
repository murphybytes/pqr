

class ThermalStorage
  include Mongoid::Document
  belongs_to :data_set

  field :units, type: Integer
  field :home_capacity, type: BigDecimal
  # if stored kw falls below this value
  # we have to charge, buying power if necessary
  field :base_threshold, type: BigDecimal
  field :storage, type: BigDecimal
  field :charge_rate, type: BigDecimal
  field :name, type: String


  index( {name: 1}, {  name: 'name_index' } )
end
