require 'spec/helper'

describe Statsd do
  class Statsd
    def socket
      @socket ||= FakeUDPSocket.new
    end
  end

  before { @statsd = Statsd.new('localhost', 1234) }
  after { @statsd.socket.clear }

  describe "#initialize" do
    it "should set the host and port" do
      @statsd.host.must_equal 'localhost'
      @statsd.port.must_equal 1234
    end
  end

  describe "#increment" do
    it "should format the message according to the statsd spec" do
      @statsd.increment('foobar')
      @statsd.socket.recv.must_equal ['foobar:1|c']
    end
  end

end
