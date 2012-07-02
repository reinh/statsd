require 'socket'

# = Statsd: A Statsd client (https://github.com/etsy/statsd)
#
# @example Set up a global Statsd client for a server on localhost:9125
#   $statsd = Statsd.new 'localhost', 8125
# @example Send some stats
#   $statsd.increment 'garets'
#   $statsd.timing 'glork', 320
#   $statsd.gauge 'bork', 100
# @example Use {#time} to time the execution of a block
#   $statsd.time('account.activate') { @account.activate! }
# @example Create a namespaced statsd client and increment 'account.activate'
#   statsd = Statsd.new('localhost').tap{|sd| sd.namespace = 'account'}
#   statsd.increment 'activate'
#
# Statsd instances are thread safe for general usage, by using a thread local
# UDPSocket and carrying no state. The attributes are stateful, and are not
# mutexed, it is expected that users will not change these at runtime in
# threaded environments. If users require such use cases, it is recommend that
# users either mutex around their Statsd object, or create separate objects for
# each namespace / host+port combination.
class Statsd
  # A namespace to prepend to all statsd calls.
  attr_reader :namespace

  # StatsD host. Defaults to 127.0.0.1.
  attr_reader :host

  # StatsD port. Defaults to 8125.
  attr_reader :port

  class << self
    # Set to a standard logger instance to enable debug logging.
    attr_accessor :logger
  end

  # @param [String] host your statsd host
  # @param [Integer] port your statsd port
  def initialize(host = '127.0.0.1', port = 8125)
    self.host, self.port = host, port
    @prefix = nil
  end

  # @attribute [w] namespace
  #   Writes are not thread safe.
  def namespace=(namespace)
    @namespace = namespace
    @prefix = "#{namespace}."
  end

  # @attribute [w] host
  #   Writes are not thread safe.
  def host=(host)
    @host = host || '127.0.0.1'
  end

  # @attribute [w] port
  #   Writes are not thread safe.
  def port=(port)
    @port = port || 8125
  end

  # Sends an increment (count = 1) for the given stat to the statsd server.
  #
  # @param [String] stat stat name
  # @param [Numeric] sample_rate sample rate, 1 for always
  # @see #count
  def increment(stat, sample_rate=1)
    count stat, 1, sample_rate
  end

  # Sends a decrement (count = -1) for the given stat to the statsd server.
  #
  # @param [String] stat stat name
  # @param [Numeric] sample_rate sample rate, 1 for always
  # @see #count
  def decrement(stat, sample_rate=1)
    count stat, -1, sample_rate
  end

  # Sends an arbitrary count for the given stat to the statsd server.
  #
  # @param [String] stat stat name
  # @param [Integer] count count
  # @param [Numeric] sample_rate sample rate, 1 for always
  def count(stat, count, sample_rate=1)
    send_stats stat, count, :c, sample_rate
  end

  # Sends an arbitary gauge value for the given stat to the statsd server.
  #
  # This is useful for recording things like available disk space,
  # memory usage, and the like, which have different semantics than
  # counters.
  #
  # @param [String] stat stat name.
  # @param [Numeric] gauge value.
  # @param [Numeric] sample_rate sample rate, 1 for always
  # @example Report the current user count:
  #   $statsd.gauge('user.count', User.count)
  def gauge(stat, value, sample_rate=1)
    send_stats stat, value, :g, sample_rate
  end

  # Sends a timing (in ms) for the given stat to the statsd server. The
  # sample_rate determines what percentage of the time this report is sent. The
  # statsd server then uses the sample_rate to correctly track the average
  # timing for the stat.
  #
  # @param [String] stat stat name
  # @param [Integer] ms timing in milliseconds
  # @param [Numeric] sample_rate sample rate, 1 for always
  def timing(stat, ms, sample_rate=1)
    send_stats stat, ms, :ms, sample_rate
  end

  # Reports execution time of the provided block using {#timing}.
  #
  # @param [String] stat stat name
  # @param [Numeric] sample_rate sample rate, 1 for always
  # @yield The operation to be timed
  # @see #timing
  # @example Report the time (in ms) taken to activate an account
  #   $statsd.time('account.activate') { @account.activate! }
  def time(stat, sample_rate=1)
    start = Time.now
    result = yield
    timing(stat, ((Time.now - start) * 1000).round, sample_rate)
    result
  end

  private

  def send_stats(stat, delta, type, sample_rate=1)
    if sample_rate == 1 or rand < sample_rate
      # Replace Ruby module scoping with '.' and reserved chars (: | @) with underscores.
      stat = stat.to_s.gsub('::', '.').tr(':|@', '_')
      rate = "|@#{sample_rate}" unless sample_rate == 1
      send_to_socket "#{@prefix}#{stat}:#{delta}|#{type}#{rate}"
    end
  end

  def send_to_socket(message)
    self.class.logger.debug { "Statsd: #{message}" } if self.class.logger
    socket.send(message, 0, @host, @port)
  rescue => boom
    self.class.logger.error { "Statsd: #{boom.class} #{boom}" } if self.class.logger
    nil
  end

  def socket
    Thread.current[:statsd_socket] ||= UDPSocket.new
  end
end
