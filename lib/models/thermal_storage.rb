

class ThermalStorage
  include Mongoid::Document
  belongs_to :data_set

  field :units, type: Integer
  field :capacity, type: BigDecimal
  # if stored kw falls below this value
  # we have to charge, buying power if necessary
  field :base_threshold, type: BigDecimal
  field :storage, type: BigDecimal
  field :charge_rate, type: BigDecimal
  field :name, type: String


  index( {name: 1}, {  name: 'name_index' } )

  def self.fetch_by_dataset( dataset, name ) 
    results = []
    DataSet.where( name: dataset ).each do | ds | 
      ThermalStorage.where( data_set_id: ds.id, name: name ).each do | ts | 
        results << ts
        yield ts 
      end
    end
    results
  end

  def pretty_print()
    puts "------------------------------------------------------"
    puts "Name: #{self.name }"
    puts "Data Set: #{ self.data_set.name }"
    puts "Units: #{ self.units }"
    puts "Capacity (kW): #{ self.capacity }"
    puts "Base Threshold (kW): #{ self.base_threshold }"
    puts "Storage (kW): #{ self.storage }"
    puts "Charge Rate (kW/hr): #{ self.charge_rate }"
    puts  ""
  end

end
