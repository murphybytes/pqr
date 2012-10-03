#!/usr/bin/env ruby
$: << File.join( Dir.pwd, 'lib' )
require 'date'
require 'mongoid'
require 'trollop'
require 'csv'
require 'models/population'
require 'models/sample'

process_row = lambda { | population, row, value_col | 
  puts row.inspect
  hours = row[2].to_i / 100
  timestamp = DateTime.new( DateTime.now.year, row[0].to_i, row[1].to_i, hours )
  population.samples << Sample.create(:timestamp => timestamp, :value => row[value_col] )


}

opts = Trollop::options do 

  opt :file, "csv file containing sample data", :type => :string
  opt :ignore_header, "Ignore first line of csv"
  opt :population_name, "Name of the population", :type => :string
  opt :environment, "development | test | production", :type => :string, :default => 'development'
  opt :column, "column to use for sample", :type => :integer
  #opt :sample_column, "Column of the csv to process", :type => :integer
end

begin

Mongoid.load!( 'config/mongoid.yml', opts[:environment].to_sym )

population = Population.find_or_create_by( name: opts[:population_name] )

CSV.foreach( opts[:file] ) do | row |
  if opts[:ignore_header]
    opts[:ignore_header] = false
    next
  end

  process_row[ population, row, opts[:column] ]
end

rescue => e
  puts "Program failed #{ e }"
  puts e.backtrace.join("\n")
end
