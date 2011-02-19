class Statsd
  attr_reader :host, :port
  def initialize(host, port)
    @host, @port = host, port
  end

  def increment(stat)
    socket.send("#{stat}:1|c")
  end

  private

  def socket
    @socket ||= UDPSocket.new(host, post)
  end
end
