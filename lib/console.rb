$: << File.join( Dir.pwd, 'lib' )



Dir.glob( "lib/**/*.rb" ) do | file |
  require file
end


environment = :development
environment = ENV['ENV'].to_sym if ENV.key?( 'ENV' )

Mongoid.load!( 'config/mongoid.yml', environment )
