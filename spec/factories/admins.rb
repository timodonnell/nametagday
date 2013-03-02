# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  sequence :email do |n|
    "basic_email#{n}@gmail.com"
  end

  factory :admin do
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    email { FactoryGirl.generate(:email) }
    password "password"
    enabled true
    password_confirmation "password"
  end
end
