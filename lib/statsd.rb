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
    send(stat, count, 'c')
  end

  def timing(stat, ms)
    send(stat, ms, 'ms')
  end

  private

  def send(stat, delta, type)
    socket.send("#{stat}:#{delta}|#{type}")
  end

  def socket
    @socket ||= UDPSocket.new(host, post)
  end
end
