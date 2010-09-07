module RemoteLogger

  # Subclass of RemoteLogger::Logger communicating via DRb protocol
  class DrbLogger < RemoteLogger::Logger

    def self.start(options = {})
      # Adding some security (disable remote eval)
      $SAFE = 1

      name = options[:name] || LOGGER_NAME

      # Creating logger instance
      logger = new options

      # Raising new RingyDingy service
      logger.info "#{name}: Initializing service with #{options}" if options[:verbose]
      DRb.start_service(options[:uri]||DRB_URI, logger)
      logger.info "#{name}: Service started with #{options}" if options[:verbose]

      DRb.thread.join

      # Never reaches this point...
      logger.info "#{name}: Service finished" if options[:verbose]
    end

    def self.find(options = {})
      DRb.start_service

      # Connecting to Logger
      DRbObject.new_with_uri(options[:uri]||DRB_URI)
    end
  end
end