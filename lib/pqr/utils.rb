
module PQR
  class Utils

    def self.holiday?( yy, mm, dd )
      ts = DateTime.new( yy, mm, dd )
      PQR::Date.where( timestamp: ts ).exists?
    end

    def self.is_peak?( ts )
      return false if Utils.holiday?( ts.year, ts.month, ts.day )
      return true
    end

  end
end
