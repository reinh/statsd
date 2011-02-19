class Statsd
  attr_reader :host, :port
  def initialize(host, port)
    @host, @port = host, port
  end

  def increment(stat)
    count stat, 1
  end

  def decrement(stat)
    count stat, -1
  end

  def count(stat, count)
    socket.send("#{stat}:#{count}|c")
  end

  def timing(stat, ms)
    socket.send("#{stat}:#{ms}|ms")
  end

  private

  def socket
    @socket ||= UDPSocket.new(host, post)
  end
end
