require 'rubygems'
require 'minitest/autorun'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'statsd'
require 'logger'

class FakeUDPSocket
  def initialize
    @buffer = []
  end

  def send(message, *rest)
    @buffer.push [message]
  end

  def recv
    res = @buffer.shift
  end

  def break!
    instance_eval do
      def send(message, *rest); raise SocketError end
    end
  end

  def clear
    @buffer = []
  end

  def to_s
    inspect
  end

  def inspect
    "<FakeUDPSocket: #{@buffer.inspect}>"
  end
end
