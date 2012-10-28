

module PQR
  class ThermalStorageModeler
    def initialize( dataset_name )
      @dataset = DataSet.where( name: dataset_name ).first 
    end
    # returns 
    # load_unserved ( the amount of demand we had that we couldn't meet )
    # load_served 
    # remaining power  ( if we have power left over )
    #
    def sink_to_thermal_storage( timestamp, generated_kw ) 
    end

  end
end
