lib_dir = File.join(File.dirname(__FILE__), "..", "lib" )
$LOAD_PATH.unshift lib_dir unless $LOAD_PATH.include?(lib_dir)
require 'remote_logger'

# Module that extends RSpec with my own extensions/macros
module SpecMacros

  # Wrapper for *it* method that extracts description from example source code, such as:
  # spec{ use{  result =  function(arg1 = 4, arg2 = 'string')  }}
  def spec &block
    it description_from(*block.source_location), &block
  end

  # reads description line from source file and drops external brackets (like *spec*{}, *use*{})
  def description_from(file, line)
    File.open(file) do |f|
      f.lines.to_a[line-1].gsub( Regexp.new('(spec.*?{)|(use.*?{)|}'), '' ).lstrip.rstrip
    end
  end
end

Spec::Runner.configure { |config| config.extend(SpecMacros) }

module RemoteLoggerTest

  # Test related Constants:
  TEST_NAME = 'MyLogger'
  TEST_STRING = 'This is test string'

  # Checks that given block does not raise any errors
  def use
    lambda {yield}.should_not raise_error
  end

  # Returns empty block (for use in spec descriptions)
  def any_block
    lambda {|*args| args}
  end

  # Sets expectations of receiving timestamped message on both logfile mock and stdout
  def logger_should_log message
    formatted_message = Time.now.strftime message
#    logfile = mock('logfile').as_null_object
#    File.stub(:new).and_return(logfile)
    @logfile_mock.should_receive(:print).with(Regexp.new(formatted_message))
    $stdout.should_receive(:print).with(Regexp.new(formatted_message))
  end
end
