# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :member do
    email Faker::Internet.email
  end
end
