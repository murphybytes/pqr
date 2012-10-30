module PQR

  # we get this number from HVAC module used in the 
  # original linknsynch model, we'll want
  # to refine this in the future
  HEATING_FACTOR=713.4889

  class Calculator
    def initialize( opts = {}  )

      @counter = 0
      @home_temp = opts.fetch( :home_temperature, 70.0 )
      @base_temp = opts.fetch( :base_temperature,  60.0 )
      @home_count = opts.fetch( :home_count, 1000 )

      @total_kw_required_for_heating = 0.0
      @total_kw_required_for_heating_ls = 0.0
      @total_load_unserved = 0.0
      @total_load_unserved_ls = 0.0
      @total_kw_generated = 0.0
      @excess_peak_capacity = 0.0
      @excess_off_peak_capacity = 0.0
      @dataset = opts.fetch( :dataset, nil )
      raise "Missing dataset in calculator, data set is required" if @dataset.nil?
      @thermal_storage = ThermalStorageModeler.new( @dataset )
      yield self if block_given?
      pretty_print
    end

    def process_sample( sample )
      result = {}
      @thermal_storage.apply_normal_usage
      handle_generated_kw( sample, result )
      calc_heating_kw_required( sample, result )
      calc_load_unserved( sample, result )

      if result[:kw_load_unserved] > 0.0
        # reduce using thermal storage if possible
        apply_thermal_to_load_unserved( result )
      else
        # try to charge thermal storage if possible
        unless  Utils.is_peak?(sample.timestamp)
          result[:excess_capacity] = [ result[:kw_generated] - result[:heating_kw_required], 0.0 ].max
          if result[:excess_capacity] > 0.0 
            used = @thermal_storage.charge( result[:excess_capacity] )
            @excess_off_peak_capacity += (result[:excess_capacity] - used )
          end
        end

      end

      @total_kw_required_for_heating_ls += result[:heating_kw_required_ls]

      yield result if block_given?
      result
    end

    def pretty_print
      puts "KW Generated                                 - #{@total_kw_generated.to_i}"
      puts "KW Required for Home Heating                 - #{@total_kw_required_for_heating.to_i}"
      puts "KW Required for Home Heating w/ Link n Synch - #{@total_kw_required_for_heating_ls.to_i}"
      puts "Load Unserved                                - #{@total_load_unserved.to_i}"
      puts "Load Unserved w/ Link n Synch                - #{@total_load_unserved_ls.to_i}"
    end


    def handle_generated_kw( sample, result )
      @total_kw_generated += sample.generated_kilowatts
      result[:kw_generated] = sample.generated_kilowatts
    end

    def calc_heating_kw_required( sample, result )
      result[:heating_kw_required] = 0.0
      if @base_temp > sample.temperature
        result[:heating_kw_required] = (( @home_temp - sample.temperature ) * HEATING_FACTOR * @home_count)/3413.0
        @total_kw_required_for_heating += result[:heating_kw_required]
      end
      result[:heating_kw_required_ls] = result[:heating_kw_required]
    end

    def calc_load_unserved( sample, result )
      result[:kw_load_unserved]  = 0.0
      if result[:kw_generated] < result[:heating_kw_required]
        result[:kw_load_unserved] = result[:heating_kw_required] - result[:kw_generated]
      end
      @total_load_unserved += result[:kw_load_unserved]
      # we will adjust link n synch number later
      @total_load_unserved_ls += result[:kw_load_unserved]
    end

    def apply_thermal_to_load_unserved( result )
      available = @thermal_storage.get_available
      adjustment = [available, result[:kw_load_unserved] ].min
      result[:kw_load_unserved_ls] = result[:kw_load_unserved] - adjustment
      result[:heating_kw_required_ls] -= adjustment
      @total_load_unserved_ls -= adjustment
      @thermal_storage.reduce_available( adjustment )
      #exit if @counter > 100
      @counter += 1
    end

  end

end
