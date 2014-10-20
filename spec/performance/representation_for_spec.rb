require 'spec_helper'
require 'benchmark'

describe 'Kartograph.representation_for Performance' do
  it "performs at it's current average" do
    map = Kartograph::Map.new
    map.property :id, :name, :email, scopes: :read

    user = double('user', id: 123, name: 'Bobby Tables', email: 'robert@creativequeries.com')
    artist = Kartograph::Artist.new(user, map)

    iterations = 10000
    summed_time = iterations.times.inject(0.0) do |sum, _|
      sum + Benchmark.realtime { artist.draw(:read) }
    end

     average = ((summed_time * 1000) / iterations)

     expect(average).to be <= 0.02
  end
end