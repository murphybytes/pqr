module PQR

  # we get this number from HVAC module used in the 
  # original linknsynch model, we'll want
  # to refine this in the future
  HEATING_FACTOR=713.4889

  class Calculator
    def initialize( opts = {}  )
      @home_temp = opts.fetch( :home_temperature, 70.0 )
      @base_temp = opts.fetch( :base_temperature,  60.0 )
      @home_count = opts.fetch( :home_count, 1000 )
      @total_kw_required_for_heating = 0.0
      @total_kw_generated = 0.0
      yield self if block_given?
      pretty_print
    end

    def process_sample( sample )
      result = {}
      result[:kw_generated] = handle_generated_kw( sample )
      result[:kw_required_for_home_heating] = calc_kw_required_for_home_heating( sample )
      yield result if block_given?
      result
    end

    def pretty_print
      puts "Total KW Generated                 - #{@total_kw_generated}"
      puts "Total KW Required for Home Heating - #{@total_kw_required_for_heating.to_i}"
    end

    private
    def handle_generated_kw( sample )
      @total_kw_generated += sample.generated_kilowatts 
      sample.generated_kilowatts
    end

    def calc_kw_required_for_home_heating( sample )
      result = 0.0
      if @base_temp > sample.temperature
        result = (( @home_temp - sample.temperature ) * HEATING_FACTOR * @home_count)/3413.0
        @total_kw_required_for_heating += result
      end
      result 
    end

  end

end
