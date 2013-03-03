require 'factory_girl'
require 'ffaker'
require 'fileutils'
require 'open-uri'


def random(array, number=1)
  array.shuffle[0..(number - 1)].first
end

def rand_in_range(from, to)
  rand * (to - from) + from
end

def rand_time(from, to)
  Time.at(rand_in_range(from.to_f, to.to_f))
end

members = []
locations = []

ActiveRecord::Base.connection.execute("TRUNCATE locations")
100.times do
  locations << FactoryGirl.create(:location)
end

ActiveRecord::Base.connection.execute("TRUNCATE members")
1000.times do
  members << FactoryGirl.create(:member, :location => random(locations))
end