#!/usr/bin/env ruby
$: << File.join( Dir.pwd, 'lib' )
require 'pqr'
require 'ostruct'
require 'optparse'


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

  dataset = DataSet.where( name: options.data_set_name ).first

  PQR::Calculator.new( dataset: dataset, base_temperature: options.base_temperature, home_count: options.home_count ) do | calc |
    puts "Working ...."

    dataset.samples.each do | sample |
      calc.process_sample( sample )
    end

  end


rescue => e
  puts "Program failed -> #{ e }"
  puts e.backtrace.join("\n")
  exit 1
end
