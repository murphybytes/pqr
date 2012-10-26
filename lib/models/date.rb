
module PQR
  class Date
    include Mongoid::Document

    field :timestamp, type: DateTime
    field :description, type: String

    def self.from_ymd( year, month, day, description = '' )
      PQR::Date.new( timestamp: DateTime.new( year, month, day ), description: description )
    end

  end

end

