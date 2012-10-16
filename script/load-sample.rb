#!/usr/bin/env ruby
$: << File.join( Dir.pwd, 'lib' )
require 'date'
require 'mongoid'
require 'optparse'
require 'ostruct'
require 'csv'

require 'models/sample'
require 'models/data_set'

GENERATED_KW=6
TEMPERATURE=3
MONTH=0
DAY=1
HOURS=2

process_row = lambda { | dataset, row |
  # only process row if generated power units is present
  unless row[GENERATED_KW].nil?
    hours = row[HOURS].to_i / 100
    timestamp = DateTime.new( DateTime.now.year, row[MONTH].to_i, row[DAY].to_i, hours )
    dataset.samples << Sample.create(:timestamp => timestamp, :temperature => row[TEMPERATURE], :generated_kilowatts => row[GENERATED_KW] )
  end

}

options = OpenStruct.new
options.filename = nil
options.ignore_header = false
options.dataset_name = nil
options.environment = "development"

opts = OptionParser.new do | opts |
  opts.banner = "Usage: load-sample.rb [options]"
  opts.separator ""
  opts.separator "Options:"


  opts.on( "-f", "--file FILENAME",  "csv file containing sample data." ) do | filename |
    options.filename = filename
  end

  opts.on( "-i", "--ignore-header", "Ignore the first line of csv." ) do 
    options.ignore_header = true
  end

  opts.on( "-d", "--data-set-name NAME", "Name of data set to contain populations." ) do | name | 
    options.dataset_name = name
  end

  opts.on( "-e", "--environment ENV", "Default #{options.environment}, Runtime environment." ) do | env | 
    options.environment = env
  end

  opts.on_tail( "-h", "--help", "Show this message." ) do 
    puts opts
    exit
  end
end

begin

  opts.parse!(ARGV)

  puts options.inspect

  Mongoid.load!( 'config/mongoid.yml', options.environment.to_sym )
  Mongoid.raise_not_found_error = false

  dataset = DataSet.find_or_create_by( name: options.dataset_name )

  puts "Working...."

  CSV.foreach( options.filename ) do | row |
    if options.ignore_header
      options.ignore_header = false
      next
    end

    process_row[ dataset, row ]

  end
  puts "Done"
rescue => e
  puts "Program failed #{ e }"
  puts e.backtrace.join("\n")
end
