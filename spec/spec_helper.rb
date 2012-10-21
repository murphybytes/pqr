


Dir.glob( 'lib/**/*.rb' ) do | path | 
  require path
end

ThermalStorage.all.delete

require 'factory_girl'

FactoryGirl.find_definitions



