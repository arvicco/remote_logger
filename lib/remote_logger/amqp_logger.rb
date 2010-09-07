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

       puts "Starting logger #{name} #{Time.now}"
#       STDOUT.flush


      # Creating logger instance
      logger = new options

      # Subscribing to direct exchange
      queue = MQ.new.queue("logger")

      queue.subscribe do |msg| logger.info msg end


    end

#
#
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