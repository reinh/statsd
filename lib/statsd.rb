class Statsd
  attr_reader :host, :port
  def initialize(host, port)
    @host, @port = host, port
  end

  def increment(stat, sample_rate=1)
    count stat, 1, sample_rate
  end

  def decrement(stat, sample_rate=1)
    count stat, -1, sample_rate
  end

  def count(stat, count, sample_rate=1)
    send stat, count, 'c', sample_rate
  end

  def timing(stat, ms, sample_rate=1)
    send stat, ms, 'ms', sample_rate
  end

  def sampled(sample_rate)
    return if sample_rate < 1 and rand > sample_rate
    yield
  end

  private

  def send(stat, delta, type, sample_rate)
    sampled(sample_rate) { socket.send("#{stat}:#{delta}|#{type}#{'|@' << sample_rate.to_s if sample_rate < 1}") }
  end

  def socket
    @socket ||= UDPSocket.new(host, post)
  end
end
