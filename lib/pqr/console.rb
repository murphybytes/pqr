


$: << File.join( Dir.pwd, 'lib' )

require 'pqr'

environment = :development
environment = ENV['PQR_ENV'].to_sym if ENV.key?( 'PQR_ENV' )

Mongoid.load!( 'config/mongoid.yml', environment )

