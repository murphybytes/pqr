#!/usr/bin/env ruby
$: << File.join( Dir.pwd, 'lib' )
require 'date'
require 'mongoid'
require 'trollop'
require 'models/sample'
require 'models/data_set'

POWER_UNIT_TO_KW_CONVERSION=19.5 * 1000
HOME_TEMP=70.0

class Calculator

  def initialize( opts )
    @opts = opts
    @total_kw_generated = 0.0
    @total_kw_required_for_heating = 0.0
    @base_temp = opts[:base_temperature] 
    @number_of_homes =  opts[:number_of_homes] 
  end

  def process_sample( sample )
    @total_kw_generated += sample.power_units
    
    if @base_temp > sample.temperature
      @total_kw_required_for_heating += (HOME_TEMP - sample.temperature) 
    end
  end

  def show_results
    puts "Total KW Generated #{(@total_kw_generated * POWER_UNIT_TO_KW_CONVERSION).to_i }"
    puts "Total KW Required for Home Heating #{ (@total_kw_required_for_heating * 713.4889 * @number_of_homes / 3413.0 ).to_i }" 
  end

end

opts = Trollop::options do 
  opt :data_set_name, "Name of data set to contain populations", :type => :string
  opt :environment, "development | test | production", :type => :string, :default => 'development'
  opt :base_temperature, "If outside temperature drops below base temperature (F) home heating is calculated", :default => 60
  opt :number_of_homes, "Number of homes used to calculate Kw load", :default => 1000
  #opt :sample_column, "Column of the csv to process", :type => :integer
end

begin

  Mongoid.load!( 'config/mongoid.yml', opts[:environment].to_sym )
  Mongoid.raise_not_found_error = false

  dataset = DataSet.where( name: opts[:data_set_name] )
 
  calculator = Calculator.new opts 

  puts "Working"

  dataset[0].samples.each do | sample |
    calculator.process_sample( sample )
  end

  puts "Done"

  calculator.show_results

rescue => e
  puts "Program failed #{ e }"
  puts e.backtrace.join("\n")
end
