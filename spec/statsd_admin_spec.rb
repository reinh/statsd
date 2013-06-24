require 'helper'

describe Statsd::Admin do
  class Statsd::Admin
    public :socket
  end

  before do
    @admin = Statsd::Admin.new('localhost', 1234)
    @socket = Thread.current[:statsd_admin_socket] = FakeTCPSocket.new
  end

  after { Thread.current[:statsd_socket] = nil }

  describe "#initialize" do
    it "should set the host and port" do
      @admin.host.must_equal 'localhost'
      @admin.port.must_equal 1234
    end

    it "should default the host to 127.0.0.1 and port to 8126" do
      statsd = Statsd::Admin.new
      statsd.host.must_equal '127.0.0.1'
      statsd.port.must_equal 8126
    end
  end

  describe "#host and #port" do
    it "should set host and port" do
      @admin.host = '1.2.3.4'
      @admin.port = 5678
      @admin.host.must_equal '1.2.3.4'
      @admin.port.must_equal 5678
    end

    it "should not resolve hostnames to IPs" do
      @admin.host = 'localhost'
      @admin.host.must_equal 'localhost'
    end

    it "should set nil host to default" do
      @admin.host = nil
      @admin.host.must_equal '127.0.0.1'
    end

    it "should set nil port to default" do
      @admin.port = nil
      @admin.port.must_equal 8126
    end
  end

  %w(gauges counters timers).each do |action|
    describe "##{action}" do
      it "should send a command and return a Hash" do
        ["{'foo.bar': 0,\n",
          "'foo.baz': 1,\n",
          "'foo.quux': 2 }\n",
          "END\n","\n"].each do |line|
          @socket.write line
        end
        result = @admin.send action.to_sym
        result.must_be_kind_of Hash
        result.size.must_equal 3
        @socket.readline.must_equal "#{action}\n"
      end
    end

    describe "#del#{action}" do
      it "should send a command and return an Array" do
        ["deleted: foo.bar\n",
         "deleted: foo.baz\n",
         "deleted: foo.quux\n",
          "END\n", "\n"].each do |line|
          @socket.write line
        end
        result = @admin.send "del#{action}", "foo.*"
        result.must_be_kind_of Array
        result.size.must_equal 3
        @socket.readline.must_equal "del#{action} foo.*\n"
      end
    end
  end

  describe "#stats" do
    it "should send a command and return a Hash" do
      ["whatever: 0\n", "END\n", "\n"].each do |line| 
        @socket.write line
      end
      result = @admin.stats
      result.must_be_kind_of Hash
      result["whatever"].must_equal 0
      @socket.readline.must_equal "stats\n"
    end
  end
end


