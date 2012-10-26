require 'factory_girl'

FactoryGirl.define do

  factory :pqrdate, class: PQR::Date do
    timestamp DateTime.new( 2012, 11, 12 )
    description 'test'
  end
end
