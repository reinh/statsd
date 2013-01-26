require 'statsd'
require 'rack'

# = RackEndpoint
#
# A Rack endpoint that accepts HTTP requests and forwards
# them on to a Statsd client.
#
# @example Set up an endpoint to collect stats at /api/stats/
#   run Statsd::RackEndpoint, $statsd, '/api/stats/'
# @example Send some stats from a jQuery-enabled page
#   $.ajax('/api/stats/increment/learn_more.next.clicked')
#
# This endpoint handles requests that look like
#
#  * `/:path_prefix/increment/:stat`
#  * `/:path_prefix/decrement/:stat`
#  * `/:path_prefix/count/:stat/:n`
#  * `/:path_prefix/gauge/:stat/:n`
#  * `/:path_prefix/set/:stat/:n`
#  * `/:path_prefix/timing/:stat/:n`
#
# It also supports a `sample_rate` query parameter.
class Statsd::RackEndpoint

  class NonNumericArgumentError < ArgumentError
    attr_reader :value
    def initialize(value, parent)
      @value = value
      super(parent)
    end
  end

  attr_reader :client

  # @param [Statsd] client the object that will make the back-end UDP requests
  #   to your statsd server.
  # @param [String] path_prefix where this endpoint is mounted. This *must*
  #   match where you actually mount the endpoint in your `config.ru`.
  def initialize(client, path_prefix = '/statsd/')
    @client = client
    @path_regex = %r{#{path_prefix}(.+)}
  end

  def call(env)
    request = Rack::Request.new(env)
    return build_response(404, 'Only POSTs are allowed') unless request.post?

    args = statsd_args(request)
    return build_response(404, 'Not a statsd request') unless args

    client.send *args
    build_response 204
  rescue NonNumericArgumentError => e
    build_response 422, "#{e.value} is not a number"
  end

  private

  def statsd_args(request)
    match = @path_regex.match(request.path)
    return nil unless match
    action, stat, value = match[1].split('/')

    result = case action
    when 'increment', 'decrement'
      [ action, stat ]
    when 'count', 'gauge', 'set', 'timing'
      [ action, stat, numeric(value) ]
    else
      nil
    end

    sample_rate = request['sample_rate']
    result.push numeric(sample_rate) if result && sample_rate
    result
  end

  def build_response(status, message = [])
    Rack::Response.new(message, status, { 'Content-Type' => 'text/plain' }).finish
  end

  def numeric(string)
    string =~ /\./ ? Float(string) : Integer(string)
  rescue ArgumentError => e
    raise NonNumericArgumentError.new(string, e)
  end

end
