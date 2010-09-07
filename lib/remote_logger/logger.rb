#encoding: UTF-8
require 'log4r'

# TODO: Set up ACL, SSL and other security stuff
module RemoteLogger
  DRB_URI = 'druby://127.0.0.1:61626'
  LOGGER_NAME = 'RemoteLogger'
  # Default service/logger name - used by Ring or retrieved via Log4R::Logger[LOGGER_NAME]
  FILE_NAME = 'remote.log'
  # File name of log file
  FILE_ENCODING = 'CP1251:UTF-8'
  # Encoding pair of log file ('File external:Ruby internal')
  STDOUT_ENCODING = 'CP866:UTF-8'
  # Encoding pair of stdout ('Stdout external:Ruby internal')
  PATTERN = '%1.1l %d - %m'
  # Log entry pattern
  DATE_PATTERN = '%Y-%m-%d %H:%M:%S.%3N'

  # A subclass of Log4r::Logger pre-configured with specific logging settings
  class Logger < Log4r::Logger
    include Log4r

    # Creates new remote logger. The following options are available:
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
    def initialize options = {}
      # define outputters: http://log4r.sourceforge.net/rdoc/files/log4r/outputter/outputter_rb.html
      if options[:outputters]
        outputters = options[:outputters]
      else
        # specify log message format: http://log4r.sourceforge.net/rdoc/files/log4r/formatter/patternformatter_rb.html
        format = PatternFormatter.new :pattern => options[:pattern]||PATTERN,
                                      :date_pattern => options[:date_pattern]||DATE_PATTERN

        # Set up IO streams with correct transcoding and conversion options: log file and (Windows) console
        conversion = {:undef=>:replace, :replace=>options[:replace]||'?'}
        file = File.new(                                  options[:file_name]||FILE_NAME, (options[:trunc] ? 'w:' : 'a:') +
                (options[:file_encoding]||FILE_ENCODING), conversion)
        $stdout.set_encoding(options[:stdout_encoding]||STDOUT_ENCODING, conversion)

        outputters = [StdoutOutputter.new('console', :formatter => format),
                      IOOutputter.new('file', file, :formatter => format)]
#   file_o = FileOutputter.new 'file', :filename => 'remote.log', :trunc => false, :formatter => format # wrong encoding
#   err_o = StderrOutputter.new 'error', :formatter => format # just in case
      end

      # create new logger named LOG_NAME
      super(options[:name]||LOGGER_NAME).tap do |logger|
        logger.outputters = outputters
        logger.info "#{name}: Logger created" if options[:verbose]
      end
    end
  end
end
