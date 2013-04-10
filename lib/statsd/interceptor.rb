require 'statsd'

class Statsd

  class Interceptor
    attr_reader :target, :statsd

    def initialize(target, statsd)
      @target, @statsd = target, statsd
    end

    def method_missing(method, *args, &block)
      stat = "#{target.class}.#{method}"
      statsd.time(stat) do
        target.send(method, *args, &block)
      end
    rescue => e
      statsd.increment("#{stat}.errors", 1)
      raise e
    end

  end

end
