
class Sample
  include Mongoid::Document

  belongs_to :data_set 

  field :temperature, type: BigDecimal
  field :generated_kilowatts, type: BigDecimal
  field :timestamp, type: DateTime
  index( {timestamp: 1}, {  name: 'timestamp_index' } )

end
