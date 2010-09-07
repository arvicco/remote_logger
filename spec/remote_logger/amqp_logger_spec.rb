#encoding: UTF-8
require_relative '../spec_helper'
require_relative 'shared_spec'

require "moqueue"
overload_amqp

module RemoteLoggerTest

  TEST_MESSAGE = "Test#{Time.now.utc}"
  describe RemoteLogger::AmqpLogger do
    before(:each) do
      File.stub!(:new) { |name, mode, opts| @logfile_mock = StringIO.new('', mode) }
    end
    after(:each) do
      reset_broker
    end

    it_should_behave_like 'Logger'

    # instead of .start, we actually test the contents of its event loop (.evented_start)
    describe '.start' do
      context 'by default, starts amqp logger service that' do
        before(:each) do
          @queue = MQ.new.queue("logger")
        end

        it 'announces logger creation'

        it 'subscribes to "logger" queue' do
          described_class.evented_start

          logger_should_log TEST_MESSAGE
          @queue.publish TEST_MESSAGE
          #@queue.should have_received_message TEST_MESSAGE
        end
      end
    end
  end
end

__END__
mq = MQ.new
05	#=> #<MQ:0x1197ae8>
06
07	queue = mq.queue("mocktacular")
08	#=> #<Moqueue::MockQueue:0x1194550 @name="mocktacular">
09
10	topic = mq.topic("lolz")
11	#=> #<Moqueue::MockExchange:0x11913dc @topic="lolz">
12
13	queue.bind(topic, :key=> "cats.*")
14	#=> #<Moqueue::MockQueue:0x1194550 @name="mocktacular">
15
16	queue.subscribe {|header, msg| puts [header.routing_key, msg]}
17	#=> nil
18
19	topic.publish("eatin ur foodz", :key => "cats.inUrFridge")
20	# cats.inUrFridge
21	# eatin ur foodz
22
23	queue.received_message?("eatin ur foodz")
24	#=> true

#          queue = mq.queue("mocktacular")
#          topic = mq.topic("lolz")
#          queue.bind(topic, :key=> "cats.*")
#          queue.subscribe { |header, msg| puts [header.routing_key, msg] }
#          topic.publish("eatin ur foodz", :key => "cats.inUrFridge")
#          p queue.received_message?("eatin ur foodz")
