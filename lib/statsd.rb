require 'socket'

# = Statsd: A Statsd client (https://github.com/etsy/statsd)
#
# Example:
#
#     statsd = Statsd.new 'localhost', 8125
#
#     statsd.increment 'garets'
#     statsd.timing 'glork', 320
class Statsd

  RESERVED_CHARS_REGEX = /[\:\|\@]/
  attr_accessor :namespace
  
  # @param [String] host your statsd host
  # @param [Integer] port your statsd port
  def initialize(host, port=8125)
    @host, @port = host, port
  end

  # @param [String] stat stat name
  # @param [Integer] sample_rate sample rate, 1 for always
  def increment(stat, sample_rate=1); count stat, 1, sample_rate end

  # @param [String] stat stat name
  # @param [Integer] sample_rate sample rate, 1 for always
  def decrement(stat, sample_rate=1); count stat, -1, sample_rate end

  # @param [String] stat stat name
  # @param [Integer] count count
  # @param [Integer] sample_rate sample rate, 1 for always
  def count(stat, count, sample_rate=1); send stat, count, 'c', sample_rate end

  # @param [String] stat stat name
  # @param [Integer] ms timing in milliseconds
  # @param [Integer] sample_rate sample rate, 1 for always
  def timing(stat, ms, sample_rate=1); send stat, ms, 'ms', sample_rate end

  def time(stat, sample_rate=1)
    start = Time.now
    result = yield
    timing(stat, ((Time.now - start) * 1000).round, sample_rate)
    result
  end

  private

  def sampled(sample_rate)
    yield unless sample_rate < 1 and rand > sample_rate
  end

  def send(stat, delta, type, sample_rate)
    prefix = "#{@namespace}." unless @namespace.nil?
    stat = stat.gsub('::', '.').gsub(RESERVED_CHARS_REGEX, '_')
    sampled(sample_rate) { socket.send("#{prefix}#{stat}:#{delta}|#{type}#{'|@' << sample_rate.to_s if sample_rate < 1}", 0, @host, @port) }
  end

  def socket; @socket ||= UDPSocket.new end
end
