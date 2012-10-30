require 'spec_helper'

describe PQR::ThermalStorageModeler do

  before(:each) do
    @data_set = FactoryGirl.build( :data_set, name: 'Set' )
     @data_set.thermal_storages << FactoryGirl.build( :thermal_storage, 
                                               name: 'WH 1',
                                               units: 100,
                                               capacity: 11.0 * 100,
                                               storage: 11.0 * 100,
                                               base_threshold: 6.0 * 100,
                                               charge_rate: 4.0 * 100,
                                               usage: 0.5 * 100
                                               )
    @data_set.thermal_storages << FactoryGirl.build( :thermal_storage, 
                                              name: 'WH 2',
                                               units: 200,
                                               capacity: 11.0 * 200,
                                               storage: 11.0 * 200,
                                               base_threshold: 6.0 * 200,
                                               charge_rate: 4.0 * 200,
                                               usage: 0.5 * 200
                                               )
    @original_storage = (( 11.0 * 200 ) + ( 11.0 * 100 ))
    @modeler = PQR::ThermalStorageModeler.new( @data_set )
  end

  it "should apply 0 charge when fully charged" do
    charge_available = ( 6.0 * 100 ) + ( 6.0 * 200 )
    @modeler.charge( charge_available ).should eq 0.0
  end

  it "should apply fractional charge when there is more charge than capacity" do
    charge = ( 6.0 * 200 ) + ( 6.0 * 100 )
    expected = ( 1.0 * 200 ) + ( 1.0 * 100 )
    @modeler.reduce_available( expected )
    @modeler.charge( charge ).should eq expected
    @modeler.total_storage.should eq @modeler.total_capacity
  end

  it "should not exceed max charge rate" do
    charge = ( 5.0 * 200 ) + ( 5.0 * 100 )
    expected = ( 4.0 * 200 ) + ( 4.0 * 100 )
    @modeler.reduce_available( ( 5.0 * 100 ) + ( 5.0 * 200 ) )
    @modeler.charge( charge ).should eq expected
  end

  it "should be creatable" do
    thermal_storage = FactoryGirl.create( :thermal_storage, name: 'Bob' )
    expect( thermal_storage ).to_not be_nil
  end

  it "total storage should be sum of each thermal storage" do
    @modeler.total_storage.should eq @original_storage
  end

  it "should reduce storage by the correct amount" do
    new_storage = @original_storage - ((0.5 * 200) + (0.5 * 100))
    @modeler.apply_normal_usage
    @modeler.total_storage.should eq new_storage
  end

  it "should correctly calculate available kws" do
    expected = ( (11.0 - 6.0)* 200 ) + ((11.0 - 6.0) * 100)
    @modeler.get_available.should eq expected
  end

  it "should correctly adjust available" do
    available = @modeler.get_available
    @modeler.reduce_available( available )
    @modeler.get_available.should eq 0.0
  end
end
