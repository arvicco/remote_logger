#encoding: UTF-8
require_relative '../spec_helper'
require_relative 'shared_spec'

require "em-spec/rspec"
require "moqueue"
overload_amqp

module RemoteLoggerTest

  TEST_MESSAGE = "Test#{Time.now.utc}"

  describe RemoteLogger::AmqpLogger, ' without EM-Spec' do
    before(:each) do
      File.stub!(:new) { |name, mode, opts| @logfile_mock = StringIO.new('', mode) }
    end

    it_should_behave_like 'Logger'
  end

  describe RemoteLogger::AmqpLogger, ' with EM-Spec' do
    include EM::Spec

    # instead of .start, we actually test the contents of its event loop (.evented_start)
    describe '.start' do
      before(:each) do
        File.stub!(:new) { |name, mode, opts| @logfile_mock = StringIO.new('', mode) }
        done
      end
      after(:each) do
        reset_broker
        done
      end

      context 'by default, starts amqp logger service that' do
        it 'subscribes to "logger" queue' do
          @queue = MQ.new.queue("logger")
          described_class.start
          logger_should_log TEST_MESSAGE
          @queue.publish TEST_MESSAGE
          # "\x04\b[\a:\tinfoI\" #{TEST_MESSAGE}\x06:\rencoding\"\nUTF-8\n"
          done
        end

        it 'supports rpc interface' do
          pending 'Unable to test since Moqueue does not support RPC, and raw EM-Spec has some other problems'
          @queue = MQ.new.queue("logger")
          described_class.start
          logger = MQ.rpc('logger')

          logger_should_log 'I %Y-%m-%d %H:%M:\d{2}.\d{3} - ' + TEST_MESSAGE
          logger.info TEST_MESSAGE
          done
        end

        context 'supports different logging priorities' do
          before(:each) do
            @topic = MQ.new.topic("topic_logger")
            described_class.start
            done
          end

          it 'supports debug log level' do
            logger_should_log 'D %Y-%m-%d %H:%M:\d{2}.\d{3} - ' + TEST_MESSAGE
            @topic.publish TEST_MESSAGE, :key => 'debug.test'
            done
          end

          it 'supports info log level' do
            logger_should_log 'I %Y-%m-%d %H:%M:\d{2}.\d{3} - ' + TEST_MESSAGE
            @topic.publish TEST_MESSAGE, :key => 'info.test'
            done
          end

          it 'supports warn log level' do
            logger_should_log 'W %Y-%m-%d %H:%M:\d{2}.\d{3} - ' + TEST_MESSAGE
            @topic.publish TEST_MESSAGE, :key => 'warn.test'
            done
          end

          it 'supports error log level' do
            logger_should_log 'E %Y-%m-%d %H:%M:\d{2}.\d{3} - ' + TEST_MESSAGE
            @topic.publish TEST_MESSAGE, :key => 'error.test'
            done
          end

          it 'supports fatal log level' do
            logger_should_log 'F %Y-%m-%d %H:%M:\d{2}.\d{3} - ' + TEST_MESSAGE
            @topic.publish TEST_MESSAGE, :key => 'fatal.test'
            done
          end

#          it 'supports custom log level' do
#            logger_should_log 'D %Y-%m-%d %H:%M:\d{2}.\d{3} - ' + TEST_MESSAGE
#            @topic.publish TEST_MESSAGE, :key => 'superpuper.test'
#            done
#          end
        end
      end

      context 'starts amqp logger service with options' do
        it 'with option :queue, subscribes to custom queue' do
          @queue = MQ.new.queue("custom")
          described_class.start(:queue => 'custom')
          logger_should_log TEST_MESSAGE
          @queue.publish TEST_MESSAGE
          done
        end

        it 'with option :exchange, binds to custom exchange' do
          @topic = MQ.new.topic('custom_topic')
          described_class.start(:exchange => 'custom_topic')
          logger_should_log 'D %Y-%m-%d %H:%M:\d{2}.\d{3} - ' + TEST_MESSAGE
          @topic.publish TEST_MESSAGE, :key => 'debug.test'
          done
        end

        it 'with option :routing_key, binds with custom routing key' do
          @topic = MQ.new.topic('topic_logger')
          described_class.start(:routing_key => '*.testkey')
          logger_should_log 'D %Y-%m-%d %H:%M:\d{2}.\d{3} - ' + TEST_MESSAGE
          @topic.publish TEST_MESSAGE, :key => 'debug.testkey'
          done
        end

        it 'with option :routing_key, only logs messages with correct routing key' do
          @topic = MQ.new.topic('topic_logger')
          described_class.start(:routing_key => '*.testkey')
          logger_should_not_log 'D %Y-%m-%d %H:%M:\d{2}.\d{3} - ' + TEST_MESSAGE
          @topic.publish TEST_MESSAGE, :key => 'debug.wrong'
          done
        end
      end
    end

    describe '.find' do
      context 'by default, finds amqp logger service that' do
        before(:each) do
          @queue = MQ.new.queue("logger")
        end
      end
    end
  end
end

__END__
it "should have direct exchanges" do
	  q = MQ.new.queue("example")
	  q.publish("hi mom!")
	  q.subscribe { |msg|
	    msg.should == "hi mom!"
	    done
	  }
end

it "should publish messages" do
	  q = MQ.new.queue("example")
      q.publish TEST_MESSAGE
      q.should have_received_message TEST_MESSAGE
      done
end