require 'statsd'

# A class which behaves exactly like {Statsd} but doens't send
# the stats to the server. It however does normal logging, so one
# can see what would be sent to sent to statsd.
#
# This class is usefull for development and testing environments.
#
# @example set $statsd depending on the RACK_ENV
#  if ENV['RACK_ENV'] == 'production'
#    $statsd = Statsd.new
#  else
#    require 'statsd/mock'
#    $statsd = Statsd::Mock.new
#  end
#  # $statsd is ready to receive stats but will only send them in production.
#
class Statsd::Mock < Statsd

private

  class UDPSocketMock

    def send(*_)
    end

  end

  def socket
    @socket ||= UDPSocketMock.new
  end

end
