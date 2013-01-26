require 'helper'
require 'rack/test'
require 'statsd/rack_endpoint'

describe Statsd::RackEndpoint do

  include Rack::Test::Methods
  attr_reader :app

  class FakeStatsClient
    attr_reader :last_received

    %w{ increment decrement count gauge set timing }.each do |m|
      define_method m do |*args|
        @last_received = [ m.to_sym, *args ]
      end
    end
  end

  before do
    @client = FakeStatsClient.new
    @app = Statsd::RackEndpoint.new(@client)
  end

  it 'accepts a statsd client' do
    @app.client.must_equal @client
  end

  it 'responds with Not Found for a POST to /somewhere/else' do
    post '/somewhere/else'
    last_response.must_be :not_found?
  end

  it 'responds with Not Found for a GET to /statsd/increment/chickens.rubber' do
    get '/statsd/increment/naps-taken'
    last_response.must_be :not_found?
  end

  it 'responds with Not Found for a POST to /statsd/reticulate/splines' do
    post '/statsd/reticulate/splines'
    last_response.must_be :not_found?
  end

  it 'responds with No Content for valid statsd requests' do
    post '/statsd/increment/kittens-mailed-to-abu-dhabi'
    last_response.status.must_equal 204
  end

  it 'forwards increments to the statsd client' do
    post '/statsd/increment/chickens.rubber'
    @client.last_received.must_equal [ :increment, 'chickens.rubber' ]
  end

  it 'forwards decrements to the statsd client' do
    post '/statsd/decrement/eaten.lasagnas'
    @client.last_received.must_equal [ :decrement, 'eaten.lasagnas' ]
  end

  it "forwards counts to the client" do
    post '/statsd/count/eaten.ferns/3'
    @client.last_received.must_equal [ :count, 'eaten.ferns', 3 ]
  end

  it 'responds to a request with a non-numeric count with a client error' do
    post '/statsd/count/eaten.pizzas/three'
    last_response.status.must_equal 422
  end

  it "forwards gagues to the client" do
    post '/statsd/gauge/weight/19582'
    @client.last_received.must_equal [ :gauge, 'weight', 19582 ]
  end

  it "forwards sets to the client" do
    post '/statsd/set/episode-number/411'
    @client.last_received.must_equal [ :set, 'episode-number', 411 ]
  end

  it "forwards timings to the client" do
    post '/statsd/timing/duration.dinner/2027'
    @client.last_received.must_equal [ :timing, 'duration.dinner', 2027 ]
  end

  it "supports a sample_rate parameter" do
    post '/statsd/timing/duration.nap/5922984?sample_rate=0.2'
    @client.last_received.last.must_equal 0.2
  end

  it "responds to a request with a non-numeric sample_rate with a client error" do
    post '/statsd/count/drunk.coffee.ounces/32?sample_rate=two-tenths'
    last_response.status.must_equal 422
  end

  it 'supports configuring the URL prefix' do
    @app = Statsd::RackEndpoint.new(@client, '/api/stats/')
    post '/api/stats/timing/duration.exercise/0'
    last_response.status.must_equal 204
  end

end
