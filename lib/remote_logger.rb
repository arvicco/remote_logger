require 'version'
require 'log4r'
require 'rinda/ring'
require 'ringy_dingy'
#require 'ringy_dingy/ring_server'

module RemoteLogger

#  require "bundler"
#  Bundler.setup

  # Requires ruby source file(s). Accepts either single filename/glob or Array of filenames/globs.
  # Accepts following options:
  # :*file*:: Lib(s) required relative to this file - defaults to __FILE__
  # :*dir*:: Required lib(s) located under this dir name - defaults to gem name
  #
  def self.require_libs( libs, opts={} )
    file = Pathname.new(opts[:file] || __FILE__)
    [libs].flatten.each do |lib|
      name = file.dirname + (opts[:dir] || file.basename('.*')) + lib.gsub(/(?<!.rb)$/, '.rb')
      Pathname.glob(name.to_s).sort.each {|rb| require rb}
    end
  end
end  # module RemoteLogger

# Require all ruby source files located under directory lib/remote_logger
# If you need files in specific order, you should specify it here before the glob
RemoteLogger.require_libs %W[logger **/*]

