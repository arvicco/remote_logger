# Gemspecs should not be generated, but edited directly.
# Refer to: http://yehudakatz.com/2010/04/02/using-gemspecs-as-intended/

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'version'
require 'date'

Gem::Specification.new do |gem|
  gem.name        = "remote_logger"
  gem.version     = ::RemoteLogger::VERSION
  gem.summary     = %q{Client/server for remote logger using multiple communication methods}
  gem.description = %q{Client/server for remote logger using multiple communication methods}
  gem.authors     = ["arvicco"]
  gem.email       = "arvitallian@gmail.com"
  gem.homepage    = %q{http://github.com/arvicco/remote_logger}
  gem.platform    = Gem::Platform::RUBY
  gem.date        = Date.today.to_s

  # Files setup
  versioned         = `git ls-files -z`.split("\0")
  gem.files         = Dir['{bin,lib,man,spec,features,tasks}/**/*', 'Rakefile', 'README*', 'LICENSE*',
                      'VERSION*', 'CHANGELOG*', 'HISTORY*', 'ROADMAP*', '.gitignore'] & versioned
  gem.executables   = (Dir['bin/**/*'] & versioned).map{|file|File.basename(file)}
  gem.test_files    = Dir['spec/**/*'] & versioned
  gem.require_paths = ["lib"]

  # RDoc setup
  gem.has_rdoc = true
  gem.rdoc_options.concat %W{--charset UTF-8 --main README.rdoc --title remote_logger}
  gem.extra_rdoc_files = ["LICENSE", "HISTORY", "README.rdoc"]
    
  # Dependencies
  gem.add_development_dependency(%q{rspec}, [">= 1.2.9"])
  gem.add_development_dependency(%q{cucumber}, [">= 0"])
  gem.add_dependency(%q{log4r}, [">= 1.1.8"])
  gem.add_dependency(%q{RingyDingy}, [">= 1.2.0"])
  #gem.add_dependency(%q{bunder}, [">= 1.2.9"])

  gem.rubyforge_project = ""
  gem.rubygems_version  = `gem -v`
  #gem.required_rubygems_version = ">= 1.3.6"
end

