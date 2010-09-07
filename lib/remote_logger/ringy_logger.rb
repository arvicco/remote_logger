require 'rinda/ring'
require 'ringy_dingy'
#require 'ringy_dingy/ring_server'

module RemoteLogger

  # Subclass of RemoteLogger::Logger communicating via DRb protocol
  class RingyLogger < Logger

    def self.start(options = {})
      # Adding some security (disable remote eval)
      $SAFE = 1

      name = options[:name] || LOGGER_NAME

      # Creating logger instance
      logger = RemoteLogger::Logger.new options

      DRb.start_service

      # Raising new RingyDingy service
      logger.info "#{name}: Initializing service with #{options}" if options[:verbose]
      RingyDingy.new(logger, name.to_sym).run
      logger.info "#{name}: Service started with #{options}" if options[:verbose]

      DRb.thread.join

      # Never reaches this point...
      logger.info "#{name}: Service finished" if options[:verbose]
    end

    def self.find(options = {})
      DRb.start_service

      name = options[:name] || LOGGER_NAME

      # Connecting to Ring server
      ring_server = Rinda::RingFinger.primary

      # Requesting logger service by name
      service = ring_server.read [:name, name.to_sym, nil, nil]
      service[2]
    end
  end
end