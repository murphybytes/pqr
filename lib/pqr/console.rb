


    $: << File.join( Dir.pwd, 'lib' )



    Dir.glob( "lib/**/*.rb" ) do | file |
      require file
    end


    environment = :development
    environment = ENV['PQR_ENV'].to_sym if ENV.key?( 'PQR_ENV' )

    Mongoid.load!( 'config/mongoid.yml', environment )

