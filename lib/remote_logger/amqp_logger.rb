require 'mq'

module RemoteLogger

  # Subclass of RemoteLogger::Logger communicating via DRb protocol
  class AmqpLogger < RemoteLogger::Logger

    def self.start(options = {})
      AMQP.start do
        evented_start options
      end
    end

    # separate actual method contents from event loop for easy testing
    def self.evented_start(options = {})
      # Adding some security (disable remote eval)
#      $SAFE = 1

      name = options[:name] || LOGGER_NAME

      # Creating logger instance
      logger = new options

      # Creating queue, subscribing to topic exchange
      queue = MQ.new.queue(options[:queue] || "logger")
      topic = MQ.new.topic(options[:exchange] || "topic_logger")
      queue.bind(topic, :key => options[:routing_key] || "#.#")

      queue.subscribe do |header, msg|
#        puts [options, header.inspect, msg]

        if header.properties[:routing_key]
          logger.send(header.routing_key.split(/\./).first.to_sym, msg)
        else
          logger.info msg
        end
      end
      #MQ.rpc(options[:queue] || 'logger', logger)
    end

#        DEBUG < INFO < WARN < ERROR < FATAL
#
#      logger.info "#{name}: Initializing service with #{options}" if options[:verbose]
#      DRb.start_service(options[:uri]||DRB_URI, logger)
#      logger.info "#{name}: Service started with #{options}" if options[:verbose]
#
#      DRb.thread.join
#
#      # Never reaches this point...
#      logger.info "#{name}: Service finished" if options[:verbose]

#
#    def self.find(options = {})
#      DRb.start_service
#
#      # Connecting to Logger
#      DRbObject.new_with_uri(options[:uri]||DRB_URI)
#    end
  end
end