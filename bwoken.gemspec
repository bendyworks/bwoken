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
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'guard-rspec'

  gem.files = [
    'bin/unix_instruments.sh',
    'lib/bwoken/formatters/colorful_formatter.rb',
    'lib/bwoken/tasks/bwoken.rake',
    'lib/bwoken/build.rb',
    'lib/bwoken/coffeescript.rb',
    'lib/bwoken/formatter.rb',
    'lib/bwoken/script.rb',
    'lib/bwoken/simulator.rb',
    'lib/bwoken/tasks.rb',
    'lib/bwoken/version.rb',
    'lib/bwoken.rb',
    'LICENSE',
    'README.md'
  ]

  gem.executables   = ['unix_instruments.sh']
  gem.name          = "bwoken"
  gem.require_paths = ["lib"]
  gem.version       = Bwoken::VERSION
end
