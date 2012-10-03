$: << File.join( Dir.pwd, 'lib' )


require 'mongoid'
require 'models/population'
require 'models/sample'
require 'models/data_set'

environment = :development
environment = ENV['ENV'].to_sym if ENV.key?( 'ENV' )

Mongoid.load!( 'config/mongoid.yml', environment )
