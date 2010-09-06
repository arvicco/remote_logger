#encoding: UTF-8
# TODO: Set up ACL, SSL and other security stuff
module RemoteLogger
  include Log4r

  DRB_URI = 'druby://127.0.0.1:61626'
  LOGGER_NAME = 'RemoteLogger' # Default service/logger name - used by Ring or retrieved via Log4R::Logger[LOGGER_NAME]
  FILE_NAME = 'remote.log' # File name of log file
  FILE_ENCODING = 'CP1251:UTF-8' # Encoding pair of log file ('File external:Ruby internal')
  STDOUT_ENCODING = 'CP866:UTF-8' # Encoding pair of stdout ('Stdout external:Ruby internal')
  PATTERN = '%1.1l %d - %m' # Log entry pattern
  DATE_PATTERN = '%Y-%m-%d %H:%M:%S.%3N'

  # Creates a new Log4r logger. The following options are available:
  #
  # <tt>:name</tt>:: Service/logger name - default 'RemoteLogger'
  # <tt>:outputters</tt>:: Replace outputters (should be Log4r::Outputter subclasses) - default [log file, stdout]
  # <tt>:file_name</tt>:: Log file name - default 'remote.log'
  # <tt>:file_encoding</tt>:: Log file encoding - default FILE_ENCODING (Windows Cyrillic)
  # <tt>:stdout_encoding</tt>:: Stdout encoding - default STDOUT_ENCODING (DOS/IBM Cyrillic)
  # <tt>:replace</tt>:: Replacement for undefined conversion chars - default '?'
  # <tt>:pattern</tt>:: Log message pattern - default PATTERN
  # <tt>:date_pattern</tt>:: Timestamp pattern - default DATE_PATTERN
  # <tt>:trunc</tt>:: Truncate (rewrite) log file upon creation  - default false (append to file)
  # <tt>:verbose</tt>:: Log all internal messages of RemoteLogger - default false (do not log logger-specific messages)
  #
  def self.create_logger options = {}
    # define outputters: http://log4r.sourceforge.net/rdoc/files/log4r/outputter/outputter_rb.html
    if options[:outputters]
      outputters = options[:outputters]
    else
      # specify log message format: http://log4r.sourceforge.net/rdoc/files/log4r/formatter/patternformatter_rb.html
      format = PatternFormatter.new :pattern => options[:pattern]||PATTERN,
                                    :date_pattern => options[:date_pattern]||DATE_PATTERN

      # Set up IO streams with correct transcoding and conversion options: log file and (Windows) console
      conversion = {:undef=>:replace, :replace=>options[:replace]||'?'}
      file = File.new(options[:file_name]||FILE_NAME, (options[:trunc] ? 'w:' : 'a:') +
              (options[:file_encoding]||FILE_ENCODING), conversion )
      $stdout.set_encoding(options[:stdout_encoding]||STDOUT_ENCODING, conversion)

      outputters = [StdoutOutputter.new('console', :formatter => format),
                    IOOutputter.new('file', file, :formatter => format) ]
#   file_o = FileOutputter.new 'file', :filename => 'remote.log', :trunc => false, :formatter => format # wrong encoding
#   err_o = StderrOutputter.new 'error', :formatter => format # just in case
    end

    # create new logger named LOG_NAME
    Logger.new(options[:name]||LOGGER_NAME).tap do |logger|
      logger.outputters = outputters
      logger.info "#{name}: Logger created" if options[:verbose]
    end
  end

  def self.start_ringy_logger(name = LOGGER_NAME, options = {})
    # Adding some security (disable remote eval)
    $SAFE = 1

    # Creating logger instance
    logger = create_logger options

    DRb.start_service

    # Raising new RingyDingy service
    logger.info "#{name}: Initializing service..." if options[:verbose]
    RingyDingy.new(logger, name.to_sym).run
    logger.info "#{name}: Service started" if options[:verbose]

    DRb.thread.join
    logger.info "#{name}: Service finished" if options[:verbose]
  end

  def self.find_ringy_logger(name = LOGGER_NAME, options = {})
    DRb.start_service
    # Connecting to Logger
    ring_server = Rinda::RingFinger.primary
    service = ring_server.read [:name, name.to_sym, nil, nil]
    service[2]
  end

  def self.start_drb_logger(name = LOGGER_NAME, options = {})
    # Adding some security (disable remote eval)
    $SAFE = 1

    # Creating logger instance
    logger = create_logger options

    # Raising new RingyDingy service
    logger.info "#{name}: Initializing service..." if options[:verbose]
    DRb.start_service(options[:uri]||DRB_URI, logger)
    logger.info "#{name}: Service started" if options[:verbose]

    DRb.thread.join
    logger.info "#{name}: Service finished" if options[:verbose]
  end

  def self.find_drb_logger(name = LOGGER_NAME, options = {})
    DRb.start_service
    # Connecting to Logger
    log = DRbObject.new_with_uri(options[:uri]||DRB_URI)
  end


end
