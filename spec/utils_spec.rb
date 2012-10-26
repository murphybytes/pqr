require 'spec_helper'

describe PQR::Utils do
  before(:all) do
    FactoryGirl.create( :pqrdate )
  end

  it "should detect if a date is a holiday" do
    PQR::Utils.holiday?(2012, 11, 12 ).should be_true
  end

end
