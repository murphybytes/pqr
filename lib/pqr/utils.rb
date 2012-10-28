
module PQR
  class Utils

    def self.holiday?( yy, mm, dd )
      ts = DateTime.new( yy, mm, dd )
      PQR::Date.where( timestamp: ts ).exists?
    end

    def self.is_peak?( ts )
      return false if Utils.holiday?( ts.year, ts.month, ts.day )
      # saturday and sunday are off peak
      return false if (ts.wday == 6 || ts.wday == 0)
      return true if (ts.hour >= 7 && ts.hour < 23)
      return false
    end

  end
end
