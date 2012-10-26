

$: << File.join( Dir.pwd, 'lib' )

require 'pqr'

require 'pqr/console'

ThermalStorage.all.delete
PQR::Date.all.delete

require 'factory_girl'

FactoryGirl.find_definitions



