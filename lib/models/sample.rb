
class Sample
  include Mongoid::Document

  belongs_to :population

  field :value, type: BigDecimal
  # Number of hours since Jan 1 1970
  field :timestamp, type: Integer
end
