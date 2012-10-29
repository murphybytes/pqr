

module PQR
  class ThermalStorageModeler
    def initialize( dataset )
      @dataset = dataset
      @unit_count = 0.0
      @dataset.thermal_storages.each { | ts | @unit_count += ts.units }
    end

    def get_available
      response = 0.0
      @dataset.thermal_storages.each do | ts |
        response += ( ts.storage - ts.base_threshold )
      end
      response 
    end

    def reduce_available( adjustment )
      @dataset.thermal_storages.each do | ts |
        portion = ( ts.units / @unit_count ) * adjustment
        ts.storage -= portion
      end
    end

    def apply_normal_usage
      @dataset.thermal_storages.each do | ts |
        if ts.storage >= ts.usage
          ts.storage -= ts.usage
        end
      end
    end

    def total_storage
      total_storage = 0.0
      @dataset.thermal_storages.each do | ts |
        total_storage += ts.storage
      end
      total_storage
    end

    def charge( kw )
    end



  end
end
