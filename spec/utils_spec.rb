require 'spec_helper'

describe PQR::Utils do
  before(:all) do
    FactoryGirl.create( :pqrdate )
  end

  it "should detect if a date is a holiday" do
    PQR::Utils.holiday?(2012, 11, 12 ).should be_true
  end

  it "should flag holiday as off peak" do
    test = DateTime.new( 2012, 11, 12, 12 )
    PQR::Utils.is_peak?(test).should be_false
  end

  it "should flag weekday during the day as on peak" do
    test = DateTime.new( 2012, 11, 13, 12 )
    PQR::Utils.is_peak?( test ).should be_true
  end

  it "should flag weekday after 11 PM as off peak" do
    test = DateTime.new( 2012, 11, 13, 23, 30, 0, '-6' )
    PQR::Utils.is_peak?( test ).should be_false
  end

  it "should flag weekday before 11 pm but after 7 pm as on peak" do 
    test = DateTime.new( 2012, 11, 13, 22, 59, 0, '-6' )
    PQR::Utils.is_peak?( test ).should be_true
  end

  it "should flag weekend of as off peak" do
    test = DateTime.new( 2012, 11, 10, 12 )
    PQR::Utils.is_peak?( test ).should be_false
  end

  it "should calculate kw required for heated water use" do
    kwh = PQR::Utils.gph_to_kwh( 54, 60 )
    kwh.to_i.should eq 8
  end

  it "should calculate energy stored in water at particular temp delta from ambient temp" do
    kwh = PQR::Utils.calc_energy_stored( 264.170083266, 68, 194 )
    kwh.round(1).should eq 81.7 
  end
end
