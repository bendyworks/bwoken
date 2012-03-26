# -*- encoding: utf-8 -*-
require File.expand_path('../lib/bwoken/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Brad Grzesiak", "Jaymes Waters"]
  gem.email         = ["brad@bendyworks.com", "jaymes@bendyworks.com"]
  gem.description   = %q{iOS UIAutomation Test Runner}
  gem.summary       = %q{Runs your UIAutomation tests from the command line for both iPhone and iPad; supports coffeescript}
  gem.homepage      = "https://github.com/bendyworks/bwoken"

  gem.add_dependency 'colorful'
  gem.add_dependency 'execjs'
  gem.add_dependency 'coffee-script-source'

  gem.files         = ['lib/bwoken.rb', 'lib/tasks/bwoken.rake']
  gem.name          = "bwoken"
  gem.require_paths = ["lib"]
  gem.version       = Bwoken::VERSION
end
