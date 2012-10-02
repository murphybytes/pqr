#!/usr/bin/env ruby
$: << File.join( Dir.pwd, 'lib' )

require 'mongoid'
require 'trollop'
require 'csv'


process_row = lambda { | row | 
puts row.inspect
}

opts = Trollop::options do 
  opt :file, "csv file containing sample data", :type => :string
  opt :ignore_header, "Ignore first line of csv"
  opt :population_name, "Name of the population", :type => :string
  #opt :sample_column, "Column of the csv to process", :type => :integer
end




CSV.foreach( opts[:file] ) do | row |
  if opts[:ignore_header]
    opts[:ignore_header] = false
    next
  end

  process_row[ row ]
end
