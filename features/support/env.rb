$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'remote_logger'
require 'spec/expectations'
require 'spec/stubs/cucumber'

require 'pathname'
BASE_PATH = Pathname.new(__FILE__).dirname + '../..'
