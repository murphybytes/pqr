#!/usr/bin/env ruby
$: << File.join( Dir.pwd, 'lib' )
require 'date'
require 'mongoid'
require 'trollop'
require 'csv'

require 'models/sample'
require 'models/data_set'

process_row = lambda { | dataset, row |
  # only process row if generated power units is present
  unless row[5].nil?
    hours = row[2].to_i / 100
    timestamp = DateTime.new( DateTime.now.year, row[0].to_i, row[1].to_i, hours )
    dataset.samples << Sample.create(:timestamp => timestamp, :temperature => row[3], :power_units => row[5] )
  end

}

opts = Trollop::options do 

  opt :file, "csv file containing sample data", :type => :string
  opt :ignore_header, "Ignore first line of csv"
  opt :data_set_name, "Name of data set to contain populations", :type => :string
  opt :environment, "development | test | production", :type => :string, :default => 'development'
  #opt :sample_column, "Column of the csv to process", :type => :integer
end

begin

  Mongoid.load!( 'config/mongoid.yml', opts[:environment].to_sym )
  Mongoid.raise_not_found_error = false

  dataset = DataSet.find_or_create_by( name: opts[:data_set_name] )

  puts "Working...."

  CSV.foreach( opts[:file] ) do | row |
    if opts[:ignore_header]
      opts[:ignore_header] = false
      next
    end

    process_row[ dataset, row ]

  end
  puts "Done"
rescue => e
  puts "Program failed #{ e }"
  puts e.backtrace.join("\n")
end
