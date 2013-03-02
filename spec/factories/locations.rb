# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :location do
    name Faker::Company.name
    address Faker::AddressUS.street_address
    city Faker::AddressUS.city
    state "NY"
    zip  Faker::AddressUS.zip_code
    country 'US'
    lat Faker::Geolocation.lat
    lng Faker::Geolocation.lng
  end
end
