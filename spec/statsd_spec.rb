require 'spec/helper'

describe Statsd do
  class Statsd
    def socket
      @socket ||= FakeUDPSocket.new
    end
  end

  before do
    @statsd = Statsd.new('localhost', 1234)
  end
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

    describe "with a sample rate" do
      before { class << @statsd; def rand; 0; end; end } # ensure delivery
      it "should format the message according to the statsd spec" do
        @statsd.increment('foobar', 0.5)
        @statsd.socket.recv.must_equal ['foobar:1|c|@0.5']
      end
end
  end

  describe "#decrement" do
    it "should format the message according to the statsd spec" do
      @statsd.decrement('foobar')
      @statsd.socket.recv.must_equal ['foobar:-1|c']
    end

    describe "with a sample rate" do
      before { class << @statsd; def rand; 0; end; end } # ensure delivery
      it "should format the message according to the statsd spec" do
        @statsd.decrement('foobar', 0.5)
        @statsd.socket.recv.must_equal ['foobar:-1|c|@0.5']
      end
    end
  end

  describe "#timing" do
    it "should format the message according to the statsd spec" do
      @statsd.timing('foobar', 500)
      @statsd.socket.recv.must_equal ['foobar:500|ms']
    end

    describe "with a sample rate" do
      before { class << @statsd; def rand; 0; end; end } # ensure delivery
      it "should format the message according to the statsd spec" do
        @statsd.timing('foobar', 500, 0.5)
        @statsd.socket.recv.must_equal ['foobar:500|ms|@0.5']
      end
    end
  end

  describe "#sampled" do
    describe "when the sample rate is 1" do
      it "should yield" do
        @statsd.sampled(1) { :yielded }.must_equal :yielded
      end
    end

    describe "when the sample rate is greater than a random value [0,1]" do
      before { class << @statsd; def rand; 0; end; end } # ensure delivery
      it "should not yield" do
        @statsd.sampled(0.5) { :yielded }.must_equal :yielded
      end
    end

    describe "when the sample rate is less than a random value [0,1]" do
      before { class << @statsd; def rand; 1; end; end } # ensure no delivery
      it "should yield" do
        @statsd.sampled(0.5) { :yielded }.must_equal nil
      end
    end

    describe "when the sample rate is equal to a random value [0,1]" do
      before { class << @statsd; def rand; 0.5; end; end } # ensure delivery
      it "should yield" do
        @statsd.sampled(0.5) { :yielded }.must_equal :yielded
      end
    end
  end

end

describe Statsd do
  describe "with a real UDP socket" do
    it "should actually send stuff over the socket" do
      socket = UDPSocket.new
      host, port = 'localhost', 12345
      socket.bind(host, port)

      statsd = Statsd.new(host, port)
      p statsd.__send__(:socket)
      statsd.increment('foobar')
      message = socket.recvfrom(16).first
      message.must_equal 'foobar:1|c'
    end
  end
end if ENV['LIVE']
