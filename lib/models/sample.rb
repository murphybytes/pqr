
class Sample
  include Mongoid::Document

  belongs_to :population

  field :value, type: BigDecimal
  field :timestamp, type: DateTime


end
