#!/usr/bin/env ruby
$: << File.join( Dir.pwd, 'lib' )
require 'date'
require 'mongoid'
require 'models/sample'
require 'models/data_set'
require 'ostruct'
require 'optparse'

HOME_TEMP=70.0

class Calculator

  def initialize( opts )
    @opts = opts
    @total_kw_generated = 0.0
    @total_kw_required_for_heating = 0.0
    @base_temp = opts.base_temperature
    @number_of_homes =  opts.home_count
  end

  def process_sample( sample )
    @total_kw_generated += sample.generated_kilowatts

    if @base_temp > sample.temperature
      @total_kw_required_for_heating += (HOME_TEMP - sample.temperature) 
    end
  end

  def show_results
    puts "Total KW Generated #{@total_kw_generated}"
    puts "Total KW Required for Home Heating #{ (@total_kw_required_for_heating * 713.4889 * @number_of_homes / 3413.0 ).to_i }" 
  end

end

options = OpenStruct.new
options.data_set_name = nil
options.environment = "development"
options.base_temperature = 60
options.home_count = 1000

opts = OptionParser.new do | opts |
  opts.banner = "Usage: summary-calculator [options]"
  opts.separator ""
  opts.separator "Options:"

  opts.on( "-d", "--data-set VALUE", "Name of data set to contain populations" ) do | value |
    options.data_set_name = value
  end

  opts.on( "-e", "--environment VALUE", "Default = #{options.environment}" ) do | value |
    options.environment = value
  end

  opts.on( "-b", "--base-temparature VALUE",  "If outside temperature drops below base temperature (F) home heating is calculated. Default = #{options.base_temperature}" ) do | value |
    options.base_temperature = value
  end

  opts.on( "-n", "--home-count VALUE", "Number of homes used to calculate Kw load. Default = #{options.home_count}" ) do | value |
    options.home_count = value
  end

  opts.on_tail( "-h", "--help", "Show this message" ) do 
    puts opts
    exit
  end
end

begin
  opts.parse!(ARGV)

  Mongoid.load!( 'config/mongoid.yml', options.environment.to_sym )
  Mongoid.raise_not_found_error = false
  raise "Missing required data set name" if options.data_set_name.nil?

  dataset = DataSet.where( name: options.data_set_name )

  calculator = Calculator.new options

  puts "Working"

  dataset[0].samples.each do | sample |
    calculator.process_sample( sample )
  end

  puts "Done"

  calculator.show_results

rescue => e
  puts "Program failed -> #{ e }"
  puts e.backtrace.join("\n")
  exit 1
end
