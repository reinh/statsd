require 'helper'
require 'statsd/mock'
require 'shared_examples'

describe Statsd::Mock do

  describe "should behave like a Statsd ducktype" do

    let(:described_class){ Statsd::Mock }

    instance_eval( &A_STATSD_DUCKTYPE )

  end

  describe "should log to global logger" do

    let(:described_class){ Statsd }

    instance_eval( &LOG_TO_STATSD_LOGGER )

  end

end
