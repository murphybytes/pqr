require 'spec_helper'

describe ThermalStorageModeler do 
  it "should be creatable" do
    thermal_storage = FactoryGirl.create( :thermal_storage, name: 'Bob' )
    expect( thermal_storage ).to_not be_nil
    
  end
end
