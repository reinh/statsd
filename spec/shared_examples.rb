# This is a set of shared test which check whether an object 
# responds to all stats sending methods.
A_STATSD_DUCKTYPE = proc do

  let(:instance){ described_class.new }

  it "should respond to :increment" do
    assert_respond_to(instance,:increment)
  end

  it "should respond to :decrement" do
    assert_respond_to(instance,:decrement)
  end

  it "should respond to :count" do
    assert_respond_to(instance,:count)
  end

  it "should respond to :gauge" do
    assert_respond_to(instance,:gauge)
  end

  it "should respond to :timing" do
    assert_respond_to(instance,:timing)
  end

  it "should respond to :time" do
    assert_respond_to(instance,:time)
  end

end

# This set of test check whether an object logs to the 
# global statsd logger.
LOG_TO_STATSD_LOGGER = proc do

  require 'stringio'

  let(:instance){ described_class.new }

  let(:buffer){ StringIO.new }

  before { Statsd.logger = Logger.new(buffer)}

  it "should write to the log in debug" do
    Statsd.logger.level = Logger::DEBUG

    instance.increment('foobar')

    buffer.string.must_match "Statsd: foobar:1|c"
  end

  it "should not write to the log unless debug" do
    Statsd.logger.level = Logger::INFO

    instance.increment('foobar')

    buffer.string.must_be_empty
  end

end
